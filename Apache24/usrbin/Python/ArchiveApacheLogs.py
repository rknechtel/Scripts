# ************************************************************************
# Script: ArchiveApacheLogs.py
# Author: Richard Knechtel
# Date: 10/31/2018
# Description: This script will Archive the Apache Log files
#
# LICENSE:
# This script is in the public domain, free from copyrights or restrictions.
#
#
# EXIT STATUS:
#     Exit codes:
#     0 = Success
#     1 = Error
#
# EXAMPLES:
#   Args format from a DOS Batch file (using either python or jython):
#   call jython D:\opt\Apache24\usrbin\Python\ArchiveApacheLogs.py yes
#   call python D:\opt\Apache24\usrbin\Python\ArchiveApacheLogs.py yes
#
#   Args format from a Shell Script (using either python or jython):
#   jython /opt/Apache24/usrbin/Python/ArchiveApacheLogs.py yes
#   python /opt/Apache24/usrbin/Python/ArchiveApacheLogs.py yes
#
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'logging',
            'os',
            'stat',
            'shutil',
            'sys',
            'time',
            'zipfile'
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)


# Custom Modules:
from modules import archiveconfig as config
from modules import genericfunctions as genfunc

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
print("")
print("Passed Arguments:")
print(sys.argv)
print("")

# Set our Variables:
# ThisScript = sys.argv[0]
# RestartApache = sys.argv[1]
# Purge = sys.argv[2]

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

CurrDate = genfunc.GetCurrentDate()

ApacheHome = os.environ["HTTP_HOME"]
ArchiveDir = "\\Archive"

# Root Logs
RootLogDir = ApacheHome + "\\logs"
RootArchiveLogDir = RootLogDir + ArchiveDir
RootLogsZipFile = CurrDate + "-Apache-RootLogs.zip"

# Security Logs
SecurityLogDir = RootLogDir + "\\security"
SecurityArchiveLogDir = SecurityLogDir + ArchiveDir
SecurityLogsZipFile = CurrDate + "-Apache-SecurityLogs.zip"


#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Script Version
ScriptVersion = '1.0'

#---------------------------------------------------------[Functions]--------------------------------------------------------

# ###################################################################################
# Function: InitArchiveLogging
# Description:  Initialize the Archive Scripts logging
# Parameters: None
#
def InitArchiveLogging():
  # Initialize the default logging system:
  config.LogPath = os.path.join(config.ApacheHome, "logs")
  config.LogFile = "ArchiveApacheLogs.log"
  # print("Log File Name = " + os.path.join(config.LogPath, config.LogFile))

  # For Debug and up Logging:
  # DeployLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),logging.DEBUG)
  # For Info and up logging
  ArchiveLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile), logging.INFO)

  return ArchiveLogger


# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: Command      - deploy/undeploy/rollback
#             Type         - hot/cold (deploy)
#             Application  - full application with extension (Example: MyApp.war)
#             AppSrv       - AppSrv instance to deploy to (Example: AppSrv01)
#
def ProcessParams(argv):
  # Set our Variables:

  # Check the total number of args passed - make sure we get 2 or 3 (2 + the script name that is passed by default).
  if(len(sys.argv) == 2):
    genfunc.ShowParams()
    config.ThisScript = sys.argv[0]
    config.RestartApache = sys.argv[1]
  elif(len(sys.argv) == 3):
    genfunc.ShowParams()
    config.ThisScript = sys.argv[0]
    config.RestartApache = sys.argv[1]
    config.Purge = sys.argv[2]
  else:
    config.ShowUsage()
    sys.exit(1)

  return

# ###################################################################################
# Function: ZipTheRootZipper
# Description: Function for zipping log directories and files recursively
# Parameters: dir - Root directory to start zipping directories/files in.
#             zip_file - Full path and name of Zip file.
#
def ZipTheRootZipper(dir, zip_file):
  print("In ZipTheRootZipper: Param - dir = " + dir)
  print("In ZipTheRootZipper: Param - zip_file = " + zip_file)

  # Create the Zip file
  zip = zipfile.ZipFile(os.path.join(dir, zip_file), 'w', compression=zipfile.ZIP_DEFLATED)
  root_len = len(os.path.abspath(dir))

  print("Zipping up Directories and Files: ")

  # Recurse through the directories and sub directories and files
  for root, dirs, files in os.walk(dir):

    # Get the Archive Root directory:
    archive_root = os.path.abspath(root)[root_len:]

    # Skip Archive/security/mod_evasive Directory:
    if 'Archive' in dirs:
      dirs.remove('Archive')

    if 'security' in dirs:
      dirs.remove('security')

    if 'mod_evasive' in dirs:
      dirs.remove('mod_evasive')

    # Skip Zip file:
    if zip_file in files:
      files.remove(zip_file)

    # Zip up all the other Directories and Files
    for file in files:
      try:
        fullpath = os.path.join(root, file)
        archive_name = os.path.join(archive_root, file)
        print(file)
        zip.write(fullpath, archive_name, zipfile.ZIP_DEFLATED)
      except Exception as e:
        print("Exception =", e)

  print("Directories and Files Zipped up - closing zip file " + os.path.join(dir, zip_file))
  # close the zip file
  zip.close()
  return zip_file

# ###################################################################################
# Function: ZipTheSecurityZipper
# Description: Function for zipping security log directories and files recursively
# Parameters: dir - Root directory to start zipping directories/files in.
#             zip_file - Full path and name of Zip file.
#
def ZipTheSecurityZipper(dir, zip_file):
  print("In ZipTheRootZipper: Param - dir = " + dir)
  print("In ZipTheRootZipper: Param - zip_file = " + zip_file)

  # Create the Zip file
  zip = zipfile.ZipFile(os.path.join(dir, zip_file), 'w', compression=zipfile.ZIP_DEFLATED)
  root_len = len(os.path.abspath(dir))

  print("Zipping up Directories and Files: ")

  # Recurse through the directories and sub directories and files
  for root, dirs, files in os.walk(dir):

    # Get the Archive Root directory:
    archive_root = os.path.abspath(root)[root_len:]

    # Skip Archive Directory:
    if 'Archive' in dirs:
      dirs.remove('Archive')

    # Skip Zip file:
    if zip_file in files:
      files.remove(zip_file)

    # Zip up all the other Directories and Files
    for file in files:
      try:
        fullpath = os.path.join(root, file)
        archive_name = os.path.join(archive_root, file)
        print(file)
        zip.write(fullpath, archive_name, zipfile.ZIP_DEFLATED)
      except Exception as e:
        print("Exception =", e)

  print("Directories and Files Zipped up - closing zip file " + os.path.join(dir, zip_file))
  # close the zip file
  zip.close()
  return zip_file

# ###################################################################################
# Function: MoveFile
# Description: Function for moving a file
# Parameters: From - The full path and file name to move
#             To - The full path and file name to move to
#
def MoveFile(From, To):
  print("In MoveFile(): From Directory = " + From + " To Directory = " + To)

  try:
    # Check if Destination file already exists - Remove Old File:
    if os.path.exists(To):
      os.remove(To)
    shutil.move(From, To)

  except PermissionError as pe:
    print("Moving file in " + From + " to " + To + " failed. PermissionError - " + pe)
    print("Exception Information= ", sys.exc_type, sys.exc_value)

  except Exception as e:
    print("Moving file in " + From + " to " + To + " failed.")
    print("Exception Information= ", sys.exc_type, sys.exc_value)


# ###################################################################################
# Function: RemoveRootLogDirsFiles
# Description: Function for removing Root log directories and files
# Parameters: Path - The full path to remove files from
#
def RemoveRootLogDirsFiles(Path):
  print("in RemoveRootLogDirsFiles: Path to remove dirs/files from = " + Path)

  try:
    print("Deleting Dirs and Files in " + Path + "Except: " + os.path.join(Path, 'Archive') + " Directory")

    # -------------------------------------------------------------------------
    # Recurse through the directories and sub directories and delete log files:
    for root, dirs, files in os.walk(Path):

      # Skip Archive/security/mod_evasive Directory:
      if 'Archive' in dirs:
        dirs.remove('Archive')

      if 'security' in dirs:
        dirs.remove('security')

      if 'mod_evasive' in dirs:
        dirs.remove('mod_evasive')

      # Delete all the files
      for file in files:
        try:
          fullpath = os.path.join(root, file)
          print("removing file = " + fullpath)

          # Check if File is Read only:
          if not os.access(fullpath, os.W_OK):
            # Directory or File is read-only, make it deleteable:
            Chmod0777(fullpath)

          # Remove File:
          os.remove(fullpath)

        except OSError as ose:
          print("OSError = ", ose)

        except Exception as e:
          print("Exception =", e)

    # -------------------------------------------------------------------------------------------
    # Recurse through the directories and sub directories and Delete all the log sub-directories:
    for root, dirs, files in os.walk(Path):

      # Skip Archive/security/mod_evasive Directory:
      if 'Archive' in dirs:
        dirs.remove('Archive')

      if 'security' in dirs:
        dirs.remove('security')

      if 'mod_evasive' in dirs:
        dirs.remove('mod_evasive')

      for dir in dirs:
        dirpath = os.path.join(root, dir)
        print("removing directory " + dirpath)
        try:
          # Remove Directories:
          os.rmdir(dirpath)
        except OSError as ose:
          print("OSError = ", ose)

        except Exception as e:
          print("Exception =", e)

  except:
    print("Removing Dirs and Files in " + Path + " failed.")
    print("Exception Information= ", sys.exc_type, sys.exc_value)


# ###################################################################################
# Function: RemoveSecurityLogDirsFiles
# Description: Function for removing Security log directories and files
# Parameters: Path - The full path to remove files from
#
def RemoveSecurityLogDirsFiles(Path):
  print("in RemoveSecurityLogDirsFiles: Path to remove dirs/files from = " + Path)

  try:
    print("Deleting Dirs and Files in " + Path + "Except: " + os.path.join(Path, 'Archive') + " Directory")

    # -------------------------------------------------------------------------
    # Recurse through the directories and sub directories and delete log files:
    for root, dirs, files in os.walk(Path):

      # Skip Archive Directory
      if 'Archive' in dirs:
        dirs.remove('Archive')

      # Delete all the files
      for file in files:
        try:
          fullpath = os.path.join(root, file)
          print("removing file = " + fullpath)

          # Check if File is Read only:
          if not os.access(fullpath, os.W_OK):
            # Directory or File is read-only, make it deleteable:
            Chmod0777(fullpath)

          # Remove File:
          os.remove(fullpath)

        except OSError as ose:
          print("OSError = ", ose)

        except Exception as e:
          print("Exception =", e)

    # -------------------------------------------------------------------------------------------
    # Recurse through the directories and sub directories and Delete all the log sub-directories:
    for root, dirs, files in os.walk(Path):

      # Skip Archive/Audit Directories
      if 'Archive' in dirs:
        dirs.remove('Archive')

      if 'Audit' in dirs:
        dirs.remove('Audit')

      for dir in dirs:
        dirpath = os.path.join(root, dir)
        print("removing directory " + dirpath)
        try:
          # Remove Directories:
          os.rmdir(dirpath)
        except OSError as ose:
          print("OSError = ", ose)

        except Exception as e:
          print("Exception =", e)

  except:
    print("Removing Dirs and Files in " + Path + " failed.")
    print("Exception Information= ", sys.exc_type, sys.exc_value)



# ###################################################################################
# Function: Chmod0777
# Description: Function for setting Full Authority Permissions on a Directory or File
# Parameters: Path - The full path to Directory or file
#
def Chmod0777(FileName):
  try:
    os.chmod(FileName, stat.S_IRWXU)  # Read, write, and execute by owner.
    os.chmod(FileName, stat.S_IRWXG)  # Read, write, and execute by group.
    os.chmod(FileName, stat.S_IRWXO)  # Read, write, and execute by others.

  except Exception as e:
    print("Exception =", e)


#-----------------------------------------------------------[Execution]------------------------------------------------------------

print("Starting ArchiveApacheLogs script.")

# ************************************
# Main Script Execution
# ************************************

# Will only run if this file is called as primary file
if __name__ == '__main__':

  ProcessParams(sys.argv)

  # Initialize Logging:
  ArchiveApacheLogger = InitArchiveLogging()

  ArchiveApacheLogger.info("Parameters = " + str(sys.argv))
  # ArchiveApacheLogger.debug("RSK Debug> In main - Parameters = " + config.RestartApache + " " + config.Purge)

  ArchiveApacheLogger.info("ApacheHome = " + config.ApacheHome)
  ArchiveApacheLogger.info("Running as User = " + config.Username)



# 1) Zip up log files.

print("Zipping up root log files for Apache in " + RootLogDir)
print("Root Logs Archive File= " + os.path.join(RootLogDir, RootLogsZipFile))
ArchiveApacheLogger.info("Zipping up root log files for Apache in " + RootLogDir)
ArchiveApacheLogger.info("Root Logs Archive File= " + os.path.join(RootLogDir, RootLogsZipFile))

# Create Root logs Zip File
print("Creating Zip file " + os.path.join(RootLogDir, RootLogsZipFile))
ArchiveApacheLogger.info("Creating Zip file " + os.path.join(RootLogDir, RootLogsZipFile))

try:
  # Zip up the root Log Directory
  ZipTheRootZipper(RootLogDir, RootLogsZipFile)

except Exception as e:
  print("Root logs, Log Archiving failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  ArchiveApacheLogger.error("Root logs, Log Archiving failed.")
  ArchiveApacheLogger.error("Exception =", e)
  ArchiveApacheLogger.error("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)


print("Zipping up Security log files for Apache in " + SecurityLogDir)
print("Security logs Archive File= " + os.path.join(SecurityLogDir, SecurityLogsZipFile))
ArchiveApacheLogger.info("Zipping up Security log files for Apache in " + SecurityLogDir)
ArchiveApacheLogger.info("Security logs Archive File= " + os.path.join(SecurityLogDir, SecurityLogsZipFile))

# Create Security logs Zip File
print("Creating Zip file " + os.path.join(SecurityLogDir, SecurityLogsZipFile))
ArchiveApacheLogger.info("Creating Zip file " + os.path.join(SecurityLogDir, SecurityLogsZipFile))

try:
  # Zip up the Security Log Directory
  ZipTheSecurityZipper(SecurityLogDir, SecurityLogsZipFile)

except Exception as e:
  print("Log Archiving failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  ArchiveApacheLogger.error("Log Archiving failed.")
  ArchiveApacheLogger.error("Exception =", e)
  ArchiveApacheLogger.error("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)


# 2) Move zipped logs to Archive directory.

# Move Root Logs zip file:
try:
  print("Moving zipped up root log files in" + RootLogDir + " for Apache to the archive directory " + RootArchiveLogDir)
  ArchiveApacheLogger.info("Moving zipped up root log files in" + RootLogDir + " for Apache to the archive directory " + RootArchiveLogDir)
  MoveFile(os.path.join(RootLogDir, RootLogsZipFile), os.path.join(RootArchiveLogDir, RootLogsZipFile))

except Exception as e:
  print("Moving zipped up log files in " + RootLogDir + " for Apache to the archive directory " + RootArchiveLogDir + " failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  ArchiveApacheLogger.error("Moving zipped up log files in " + RootLogDir + " for Apache to the archive directory " + RootArchiveLogDir + " failed.")
  ArchiveApacheLogger.error("Exception =", e)
  ArchiveApacheLogger.error("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)

# Move Security Logs zip file:
try:
  print("Moving zipped up security log files in" + SecurityLogDir + " for Apache to the archive directory " + SecurityArchiveLogDir)
  ArchiveApacheLogger.info("Moving zipped up security log files in" + SecurityLogDir + " for Apache to the archive directory " + SecurityArchiveLogDir)
  MoveFile(os.path.join(SecurityLogDir, SecurityLogsZipFile), os.path.join(SecurityArchiveLogDir, SecurityLogsZipFile))

except Exception as e:
  print("Moving zipped up log files in " + SecurityLogDir + " for Apache to the archive directory " + SecurityArchiveLogDir + " failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  ArchiveApacheLogger.error("Moving zipped up log files in " + SecurityLogDir + " for Apache to the archive directory " + SecurityArchiveLogDir + " failed.")
  ArchiveApacheLogger.error("Exception =", e)
  ArchiveApacheLogger.error("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)


# If the move of the zip file didn't fail remove the old files
# 3) Delete log files in logs directory.

# Remove Root Logs
try:
  print("Removing original root log files for Apache after archiving.")
  ArchiveApacheLogger.info("Removing original root log files for Apache after archiving.")
  RemoveRootLogDirsFiles(RootLogDir)

except Exception as e:
  print("Removing original root log files for Apache after archiving failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  ArchiveApacheLogger.error("Removing original root log files for Apache after archiving failed.")
  ArchiveApacheLogger.error("Exception =", e)
  ArchiveApacheLogger.error("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)

# Remove Security Logs
try:
  print("Removing original security log files for Apache after archiving.")
  ArchiveApacheLogger.info("Removing original security log files for Apache after archiving.")
  RemoveSecurityLogDirsFiles(SecurityLogDir)

except Exception as e:
  print("Removing original security log files for Apache after archiving failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  ArchiveApacheLogger.error("Removing original security log files for Apache after archiving failed.")
  ArchiveApacheLogger.error("Exception =", e)
  ArchiveApacheLogger.error("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)

# Check if we need to purge any log files
if PurgeDays > 0:
  # Purge Archived Root Log files:
  print("Purging Archived Root Log files greater than or equal to " + PurgeDays + " days old.")
  ArchiveApacheLogger.info("Purging Archived Root Log files greater than or equal to " + PurgeDays + " days old.")
  genfunc.Purge(RootArchiveLogDir, PurgeDays)

  # Purge Archived Security Log files:
  print("Purging Archived Root Log files greater than or equal to " + PurgeDays + " days old.")
  ArchiveApacheLogger.info("Purging Archived Root Log files greater than or equal to " + PurgeDays + " days old.")
  genfunc.Purge(SecurityArchiveLogDir, PurgeDays)


# All Went well - exiting!
print("ArchiveApacheLogs completed successfully!")
sys.exit(0)