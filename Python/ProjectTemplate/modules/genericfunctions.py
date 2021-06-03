# ###################################################################################
# Script/module: modules\genericfunctions.py
# Author: Richard Knechtel
# Date: 01/17/2018
# Description: This is a module of generic functions
# Python Version: 3.8.x
#
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# ###################################################################################
#from _overlapped import NULL


# ---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'datetime',
            'logging',
            'logging.handlers',            
            'os',
            'psutil',
            'shutil',
            'subprocess',
            'sys',
            'tempfile',
            'time',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)

# ---------------------------------------------------------[Initialisations]--------------------------------------------------------

global GenFuncLogger

# ---------------------------------------------------------[Functions]----------------------------------------------------

# ###################################################################################
# Function: InitScriptConsoleLogging
# Description:  Initialize the Scripts Console logging
# Parameters: None
#
# # Exmaple Usage:
# MyLogger = genfunc.InitScriptConsoleLogging(__name__, config.LogLevel)
#
def InitScriptConsoleLogging(logger_name,log_level):
  # Initialize the default logging system:

  # Create our Logger
  MyScriptLogger = CreateConsoleLogger(logger_name, log_level)

  return MyScriptLogger

# ###################################################################################
# Function: CreateConsoleLogger
# Description: This will log to std.out (console)
# Parameters: 
#             LoggerName - Name of Logger to use
#             Loglevel - Loging level to use (see below)
#
# mode/filemodes:
# a = append 
# w = write
#
# Logging Levels:
# logging.CRITICAL (50) - Usage: logging.critical(<message>)
# logging.ERROR (40)    - Usage: logging.error(<message>)
# logging.WARNING (30)  - Usage: logging.warning(<message>)
# logging.INFO (20)     - Usage: logging.info(<message>)
# logging.DEBUG (10)    - Usage: logging.debug(<message>)
# logging.NOTSET (0)
#
# To Check if a logger is enable for a specific logging level
# Note: Can be expensive in deeply nested loggers
# if logger.isEnabledFor(logging.DEBUG):
#
def CreateConsoleLogger(LoggerName, Loglevel):

  # Get logger for passed in LoggerName
  MyLogger = logging.getLogger(LoggerName)
  MyLogger.setLevel(Loglevel)
    
  # Create the log message handler (to console)
  LogFileHandler = logging.StreamHandler(sys.stdout)
    
  # Set the Logging Format
  formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
  LogFileHandler.setFormatter(formatter)
  LogFileHandler.setLevel(Loglevel)

  # Append the Console StreamHandler:
  MyLogger.addHandler(LogFileHandler)
  
  return MyLogger

# ###################################################################################
# Function: InitScriptFileLogging
# Description:  Initialize the Scripts File Logging
# Parameters: None
#
def InitScriptFileLogging(logger_name, log_path, file_name, log_level):
  # Initialize the default logging system:
  
  # Check if Log directory exists, if it doens't create it
  DirExists = os.path.isdir(log_path)
  if DirExists==False:
    try:
      os.mkdir(log_path)
    except OSError:
      print("Creation of the directory %s failed" % log_path)
    else:
      print("Successfully created the directory %s" % log_path) 
  

  # Create our Logger
  MyScriptLogger = CreateFileLogger(__name__, os.path.join(log_path, file_name), log_level)

  return MyScriptLogger

# ###################################################################################
# Function: CreateFileLogger
# Description:  Initialize/Create logger
# Parameters: 
#             LoggerName - Name of Logger to use
#             FileName - Full Path Log File Name
#             Loglevel - Loging level to use (see below)
#
# mode/filemodes:
# a = append 
# w = write
#
# Logging Levels:
# logging.CRITICAL (50) - Usage: logging.critical(<message>)
# logging.ERROR (40)    - Usage: logging.error(<message>)
# logging.WARNING (30)  - Usage: logging.warning(<message>)
# logging.INFO (20)     - Usage: logging.info(<message>)
# logging.DEBUG (10)    - Usage: logging.debug(<message>)
# logging.NOTSET (0)
#
# To Check if a logger is enable for a specific logging level
# Note: Can be expensive in deeply nested loggers
# if logger.isEnabledFor(logging.DEBUG):
#
def CreateFileLogger(LoggerName, FileName, Loglevel):

  # Get logger for passed in LoggerName
  MyLogger = logging.getLogger(LoggerName)
  MyLogger.setLevel(Loglevel)
   
    
  # Create the log message handler
  # maxBytes: 10485760 = 10 MB
  LogFileHandler = logging.handlers.RotatingFileHandler(FileName, mode='a', maxBytes=10485760, backupCount=5)
    
  # Set the Logging Format
  formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
  LogFileHandler.setFormatter(formatter)

  # Append the RotatingFileHandler:
  MyLogger.addHandler(LogFileHandler)
  
  return MyLogger



# ###################################################################################
# Function: ShowParams
# Description:  Display Parameters passed to script
# Parameters: None
#
def ShowParams():
  NumArgs = len(sys.argv)
  print("")
  print("Passed Arguments:")
  
  for x in range(1, NumArgs):  
    print(sys.argv[x])

  print("")

  return


# ###################################################################################
# Function: GetCurrentDate
# Description: Will return the current date and time formatted as:
#              YYYY-MM-DD
# Parameters: None
#
def GetCurrentDate():
  Current_Time = datetime.datetime.now()

  return Current_Time.strftime("%Y-%m-%d")



# ###################################################################################
# Function: GetCurrentDateTime
# Description: Will return the current date and time formatted as:
#              YYYY-MM-DD HH:MM:SS
# Parameters: None
#
def GetCurrentDateTime():
  Current_Time = datetime.datetime.now()

  return Current_Time.strftime("%Y-%m-%d %H:%M:%S")


# ###################################################################################
# Function: GetReadableDateTime
# Description: Will return the passed Time In Seconds in readable Date/Time format
#              Example: 10/31/2018 12:15:45
# Parameters:
#
def GetReadableDateTime(TimeInSeconds):

  ts = time.localtime(TimeInSeconds)
  
  return time.strftime("%m/%d/%Y %H:%M:%S", ts)


# ###################################################################################
# Function: MoveFile
# Description: Function for moving a file  
# Parameters: From - The full path and file name to move
#             To - The full path and file name to move to
#             MyLogger - The logger to use for logging (Optional)
#
def MoveFile(From, To, MyLogger):

  if MyLogger is None:
    GenFuncLogger = MyLogger
    GenFuncLogger.info("In MoveFile(): From Directory = " + From + " To Directory = " + To)
  else:
    print("In MoveFile(): From Directory = " + From + " To Directory = " + To)

  try:
    # Check if Destination file already exists - Remove Old File:      
    if os.path.exists(To):
      os.remove(To)
    shutil.move(From, To)     

  except PermissionError as pe:
    if MyLogger is None:
      GenFuncLogger.error("Moving file in " + From + " to " + To + " failed. PermissionError - " + pe)
      GenFuncLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
    else:
      print("Moving file in " + From + " to " + To + " failed. PermissionError - " + pe)
      print("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
      
  except Exception as e:
    if MyLogger is None:
      GenFuncLogger.error("Moving file in " + From + " to " + To + " failed.")
      GenFuncLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
    else:
      print("Moving file in " + From + " to " + To + " failed.")
      print("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])    
        
  return    


# ###################################################################################
# Function: Remove
# Description: Will remove a directory or file
# Parameters: Path - Path to rmeove (either a directory or file)
#
def Remove(Path):

  # Remove the file or directory
  if os.path.isdir(path):
      try:
          os.rmdir(path)
      except OSError as ose:
          print("Remove(): Unable to remove folder: %s" % path, ose)
  else:
      try:
          if os.path.exists(path):
              os.remove(path)
      except OSError as ose:
          print("Remove(): Unable to remove file: %s" % path, ose)
  return

# ###################################################################################
# Function: Chmod0777
# Description: Function for setting Full Authority Permissions on a Directory or File 
# Parameters: FileName - The full path to Directory or file
# 
def Chmod0777(FileName):
  try:
    os.chmod(FileName, stat.S_IRWXU) # Read, write, and execute by owner.
    os.chmod(FileName, stat.S_IRWXG) # Read, write, and execute by group.
    os.chmod(FileName, stat.S_IRWXO) # Read, write, and execute by others.

  except Exception as e:
    print("Exception in Chmod0777() =", e)


# ###################################################################################
# Function: GetTempDir()
# Description: This will return a platform agnostic Temp directory location.
# Parameters: None
#
def GetTempDir():
  TempDir = tempfile.gettempdir()
  return TempDir


# ###################################################################################
# Function: GetTempDir()
# Description: This will return a platform agnostic Semi-Private Temp directory 
#              location.
# Parameters: None
#
def GetSemiPrivateTempDir():
  TempDir = os.path.join(GetTempDir(), '.{}'.format(hash(os.times())))
  os.makedirs(TempDir)
  return TempDir
 

# ###################################################################################
# Function: CleanTempDir()
# Description:  This will clean out the platform agnostic Temp directory.
#               (for for privacy, resources, security, whatever reason.)
# Parameters: TempDirectory - Temp Directory to Clean out
#
def CleanTempDir(TempDirectory):
  shutil.rmtree(TempDirectory, ignore_errors=True)
  return


# ###################################################################################
# Function: Puge
# Description: This will purge files in a directory older than the number of days
#              specified
# Parameters: PurgeDirectory - Directory to purge files in
#             NumDays - Days Older than to Purge (Example: 30)
#
# Possible Improvements:
#   Add logging so you know what got deleted or what didn’t (or both)
#   Make the function able to accept a range of dates or a list of dates to delete
#
def Purge(PurgeDirectory, NumDays):

  # Removes files from the passed in path that are older than or equal
  # to the number_of_days

  # Get the number of days in seconds:
  # Current Time - (Number of Days * Hours in a Day * Minutes in a Hour * Seconds in a Minute)
  TimeInSeconds = time.time() - (NumDays * 24 * 60 * 60)

  for root, dirs, files in os.walk(PurgeDirectory, topdown=False):
      for file_ in files:
          FullPath = os.path.join(root, file_)
          stat = os.stat(FullPath)

          # stat.st_size = size of file, in bytes.
          # stat.st_mtime = time of most recent content modification.
          if stat.st_mtime <= TimeInSeconds:
              print("Purge(): Removing File: " + FullPath + " with file size of " + stat.st_size + " bytes")
              remove(FullPath)

      # Commented out - only use if we want to remover the "root" directory itself
      # we are deleting files from.
      # if not os.listdir(root):
      #    remove(root)

  return


# ###################################################################################
# Function: killProcess
# Description: Will kill a Process by it's Process ID
# Parameters: ProcPID - Process ID
#
def killProcess(ProcPID):
  process = psutil.Process(ProcPID)

  for proc in process.children(recursive=True):
    proc.kill()

  process.kill()

  return


# ###################################################################################
# Function: PrintStatInfo
# Description: Will print the statistics for a given path/file.
# Parameters: Path/File
#
# Example Call from DOS:
# python -c "from modules import genericfunctions as genfunc; genfunc.PrintStatInfo('C:\\Projects\\Middleware-E46\\Wildfly\\Scripts\\Windows\\Apache\\usrbin\\Python\\modules\\archiveconfig.py')"
#
def PrintStatInfo(StatPath):

  statinfo = os.stat(StatPath)

  print("Statistics for: " + StatPath)
  print("***************************************************************************************************************")
  print(" ")
  print("Protection Bits = " + str(statinfo.st_mode))
  print("INode Number = " + str(statinfo.st_ino))
  print("Device = " + str(statinfo.st_dev))
  print("Number of Hard Links = " + str(statinfo.st_nlink))
  print("User Id of Owner = " + str(statinfo.st_uid))
  print("Group Id of Owner = " + str(statinfo.st_gid))
  print("Size of File in Bytes = " + str(statinfo.st_size))
  print("Time of Most Recent Access = " + GetReadableDateTime(statinfo.st_atime))
  print("Time of Most Recent Content Modification = " + GetReadableDateTime(statinfo.st_mtime))
  print("Time of Most Recent Metadata Change = " + GetReadableDateTime(statinfo.st_ctime))
  print(" ")
  print("***************************************************************************************************************")

  return
  
# ###################################################################################
# Function: cmp
# Description:  
#    Replacement for built-in function cmp that was removed in Python 3
#    Compare the two objects x and y and return an integer according to
#    the outcome. 
#    The return value is: 
#      negative if x < y 
#      positive if x > y
#      zero if x == y
# Parameters: 
#  x = First item to compare
#  y = Second item to compare
#
def cmp(x, y):
  print('cmp(x=' + x + ' y=' +y)
  if x < y:
    return -1
  elif x > y:
    return 1
  else:
    return 0


# This is a Function template:
# ###################################################################################
# Function: 
# Description:  
# Parameters: 
#
def MyFuncation(Param1, Param2):

  return