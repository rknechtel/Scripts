
# ************************************************************************
# Script: ArchiveLogs.py
# Author: Richard Knechtel
# Date: 01/03/2018
# Description: This script will Archive Log files
# 
# Version: 1.0
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
#   call jython D:\opt\Wildfly\usrbin\Python\ArchiveLogs.py AppSrv01 01-08-2018-AppSrv01-Logs.zip
#   call python D:\opt\Wildfly\usrbin\Python\ArchiveLogs.py AppSrv01 01-08-2018-AppSrv01-Logs.zip
#
#   Args format from a Shell Script (using either python or jython):
#   jython /opt/Wildfly/usrbin/Python/ArchiveLogs.py AppSrv01 01-08-2018-AppSrv01-Logs.zip
#   python /opt/Wildfly/usrbin/Python/ArchiveLogs.py AppSrv01 01-08-2018-AppSrv01-Logs.zip
#
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

import os
import sys
import stat
import shutil
import zipfile

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
print("")
print("Passed Arguments:")
print(sys.argv)
print("")

# Set our Variables:
ThisScript = sys.argv[0]
AppSrv = sys.argv[1]
ZipFile = sys.argv[2]

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

JbossHome = os.environ["JBOSS_HOME"]
LogDir = JbossHome + "\\" + AppSrv + "\\log"
ArchiveLogDir = LogDir + "\\Archive"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

#---------------------------------------------------------[Functions]--------------------------------------------------------

# ###################################################################################
# Function: ZipTheZipper
# Description: Function for zipping log directories and files recursively  
# Parameters: dir - Root directory to start zipping directories/files in.
#             zip_file - Full path and name of Zip file.
#
def ZipTheZipper(dir, zip_file):
  print("In ZipTheZipper: Param - dir = " + dir)
  print("In ZipTheZipper: Param - zip_file = " + zip_file)

  # Create the Zip file
  zip = zipfile.ZipFile(os.path.join(LogDir, ZipFile), 'w', compression=zipfile.ZIP_DEFLATED)
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
    if ZipFile in files:
      files.remove(ZipFile)
        
    # Zip up all the other Directories and Files
    for file in files:
      try:
        fullpath = os.path.join(root, file)
        archive_name = os.path.join(archive_root, file)
        print(file)
        zip.write(fullpath, archive_name, zipfile.ZIP_DEFLATED)
      except Exception as e:
        print("Exception =", e)
        
  print("Directories and Files Zipped up - closing zip file " + os.path.join(LogDir, ZipFile))
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
# Function: RemoveLogDirsFiles
# Description: Function for removing log directories and files 
# Parameters: Path - The full path to remove files from
#   
def RemoveLogDirsFiles(Path):
  print("in RemoveDirsFiles: Path to remove dirs/files from = " + Path)
  
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
      
      # Skip Archive Directory
      if 'Archive' in dirs:
        dirs.remove('Archive')
                    
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
    os.chmod(FileName, stat.S_IRWXU) # Read, write, and execute by owner.
    os.chmod(FileName, stat.S_IRWXG) # Read, write, and execute by group.
    os.chmod(FileName, stat.S_IRWXO) # Read, write, and execute by others.

  except Exception as e:
    print("Exception =", e)

   
#-----------------------------------------------------------[Execution]------------------------------------------------------------

print("Starting ArchiveLogs script.")

# 1) Zip up log files.

print("Zipping up log files for " + AppSrv + " in " + LogDir)
print("Archive File= " + os.path.join(LogDir, ZipFile))

# Create Zip File
print("Creating Zip file " + os.path.join(LogDir, ZipFile))
  
try:
  # Zip up log files and log directories at root of log directory:
  ZipTheZipper(LogDir, ZipFile)

except Exception as e:
  print("Log Archiving failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)


# 2) Move zipped logs to Archive directory.
try:
  print("Moving zipped up log files in" + LogDir + " for " + AppSrv + " to the archive directory " + ArchiveLogDir)  
  MoveFile(os.path.join(LogDir, ZipFile), os.path.join(ArchiveLogDir, ZipFile))

except Exception as e:
  print("Moving zipped up log files in " + LogDir + " for " + AppSrv + " to the archive directory " + ArchiveLogDir  + " failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)


# If the move of the zip file didn't fail remove the old files
# 3) Delete log files in logs directory.
try:
  print("Removing original log files for " + AppSrv + " after archiving.")
  RemoveLogDirsFiles(LogDir)

except Exception as e:
  print("Removing original log files for " + AppSrv + "after archiving failed.")
  print("Exception =", e)
  print( "Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)

# All Went well - exiting!
print("ArchiveLogs completed successfully!")
sys.exit(0)
