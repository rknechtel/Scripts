# ************************************************************************
# Script: MyScript.py
# Author: Your Name
# Date: Create Date (MM/DD/YYYY)
# Description: This script ......
# Python Version: 3.8.x
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
#   Args format from a DOS Batch file (using python):
#   call python Drive:\Path\MyScript.py Param1 Param2
#
#   Args format from a Shell Script (using python3):
#   python3 /Path/MyScript.py Param1 Param2
#
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'getpass',
            'os',
            'sys',
            'errno',
            'logging',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)

	
# Custom Modules:
from config import MyScriptconfig as config
from modules import genericfunctions as genfunc


#---------------------------------------------------------[Script Parameters]------------------------------------------------------
print("")
print("Passed Arguments:")
print(sys.argv)
print("")

# Set our Variables:
Param1 = sys.argv[0]
Param2 = sys.argv[1]


#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Platform agnostic way to get User
Username = getpass.getuser()

# Parameters to Script:
global ThisScript
global Param1
global Param2

# Logging
global LogPath
global LogFile

global MyScriptLogger

# Logging (File):
 config.LogPath = "C:\Temp\Log"
 config.LogFile = "MyScript.log"
  
# For Info and up logging
config.LogLevel = logging.INFO
# For Debug and up Logging:
#config.LogLevel = logging.DEBUG

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '0.0.1'

#---------------------------------------------------------[Functions]--------------------------------------------------------
  
# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: Param1      - Does
#             Param2         - Does
#
def ProcessParams(argv):
  # Set our Variables:

  # Check the total number of args passed - make sure we get 3 (2 + the script name that is passed by default).
  if(len(sys.argv) == 3):
    genfunc.ShowParams()
    ThisScript = sys.argv[0]
    Param1 = sys.argv[1]
    Param2 = sys.argv[2]

  else:
    config.ShowUsage()
    sys.exit(1)

  return

# This is a Function template:
# ###################################################################################
# Function:
# Description:
# Parameters:
#
def MyFuncation(Param1, Param2):
  print("In MyFuncation():")

  try:
    # Do Something
    print("Doing Something")

  except Exception as e:
    print("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])

  return
   
 
#-----------------------------------------------------------[Execution]------------------------------------------------------------

# ************************************
# Main Script Execution
# ************************************

# Will only run if this file is called as primary file 
if __name__ == '__main__':
  print("Starting MyScript script.")

  
  try:
    # Note: Choose to use either File Logging or Console Logging. Console Logging is best for use in AWS.
	# Initialize File Logging:
    MyScriptLogger = InitScriptFileLogging(MyScript, config.LogPath, config.LogFile, config.LogLevel)
    
    # INitialize Console Logging:
    MyScriptLogger = genfunc.InitScriptConsoleLogging(MyScript, config.LogLevel)

    # Proccess Parameters
    ProcessParams(sys.argv)

	# Do Something
    print("Doing Something")
    MyScriptLogger.info("Doing Something")


  except Exception as e:
    MyScriptLogger.info("MyScript script Ended at " + genfunc.GetCurrentDateTime() + ".")
    MyScriptLogger.error("Execution failed.")
    MyScriptLogger.error("Exception Information = " + traceback.format_exc())
    MyScriptLogger.error("")
    MyScriptLogger.error("MyScript.py completed unsuccessfully at " + genfunc.GetCurrentDateTime() + ".")
    config.HasError = True
    sys.exit(1)


  if not config.HasError:
    # All Went well - exiting!
    MyScriptLogger.info("MyScript script Ended at " + genfunc.GetCurrentDateTime() + ".")
    MyScriptLogger.info("")
    MyScriptLogger.info("MyScript.py completed successfully at " + genfunc.GetCurrentDateTime() + ".")
    MyScriptLogger.info("")
    MyScriptLogger.info("========================================================")
    MyScriptLogger.info("")
    config.HasError = False
    sys.exit(0)

