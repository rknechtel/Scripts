# ###################################################################################
# Script/module: modules\genericfunctions.py
# Author: Richard Knechtel
# Date: 01/17/2018
# Description: This is a module of generic functions
#
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# ###################################################################################
from _overlapped import NULL


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
# Function: CreateLogger
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
# logging.CRITICAL  - Usage: logging.critical(<message>)
# logging.ERROR     - Usage: logging.error(<message>)
# logging.WARNING   - Usage: logging.warning(<message>)
# logging.INFO      - Usage: logging.info(<message>)
# logging.DEBUG     - Usage: logging.debug(<message>)
# logging.NOTSET
#
# To Check if a logger is enable for a specific logging level
# Note: Can be expensive in deeply nested loggers
# if logger.isEnabledFor(logging.DEBUG):
#
def CreateLogger(LoggerName, FileName, Loglevel):

  # Get logger for passed in LoggerName
  GenericLogger = logging.getLogger(LoggerName)
  GenericLogger.setLevel(Loglevel)
   
    
  # Create the log message handler
  # maxBytes: 10485760 = 10 MB
  LogFileHandler = logging.handlers.RotatingFileHandler(FileName, mode='a', maxBytes=10485760, backupCount=5)
    
  # Set the Logging Format
  formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
  LogFileHandler.setFormatter(formatter)

  # Append the RotatingFileHandler:
  GenericLogger.addHandler(LogFileHandler)
  
  return GenericLogger



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

def killProcess(proc_pid):
  process = psutil.Process(proc_pid)
  for proc in process.children(recursive=True):
    proc.kill()
  process.kill()

  
  
# This is a Function template:
# ###################################################################################
# Function: 
# Description:  
# Parameters: 
#
def MyFuncation(Param1, Param2):

  return