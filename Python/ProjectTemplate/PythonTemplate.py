# ************************************************************************
# Script: MyScript.py
# Author: Your Name
# Date: Create Date (MM/DD/YYYY)
# Description: This script ......
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
#   Args format from a DOS Batch file (using either python):
#   call python Drive:\Path\MyScript.py Param1 Param2
#
#   Args format from a Shell Script (using either python):
#   python /Path/MyScript.py Param1 Param2
#
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
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

Username = os.environ["USERNAME"]

# Parameters to Script:
global ThisScript
global Param1
global Param2

# Logging
global LogPath
global LogFile

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

#---------------------------------------------------------[Functions]--------------------------------------------------------

# ###################################################################################
# Function: InitScriptLogging
# Description:  Initialize the Scripts logging
# Parameters: None
#
def InitScriptLogging():
  # Initialize the default logging system:
  LogPath = "C:\Temp\Log"
  LogFile = "MyScript.log" 
  #print("Log File Name = " + os.path.join(LogPath, LogFile))
  
  # Check if Log directory exists, if it doens't create it
  DirExists = os.path.isdir(config.LogPath)
  if DirExists==False:
    try:
      os.mkdir(config.LogPath)
    except OSError:
      print("Creation of the directory %s failed" % config.LogPath)
    else:
      print("Successfully created the directory %s" % config.LogPath) 
  
  # For Debug and up Logging:
  #ScriptLogger = genfunc.CreateLogger(__name__, os.path.join(LogPath, LogFile),logging.DEBUG)
  # For Info and up logging
  ScriptLogger = genfunc.CreateLogger(__name__, os.path.join(LogPath, LogFile),logging.INFO)

  return ScriptLogger
  
# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: Param1      - Does
#             Param2         - Does
#
def ProcessParams(argv):
  # Set our Variables:

  # Check the total number of args passed - make sure we get 5 (4 + the script name that is passed by default).
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
    print("Exception Information= ", sys.exc_type, sys.exc_value)

  return
   
 
#-----------------------------------------------------------[Execution]------------------------------------------------------------

# ************************************
# Main Script Execution
# ************************************

# Will only run if this file is called as primary file 
if __name__ == '__main__':
  print("Starting MyScript script.")

  
  try:
	# Initialize Logging:
    ScriptLogger = InitScriptLogging()

    # Proccess Parameters
    ProcessParams(sys.argv)

	# Do Something
    print("Doing Something")

  except Exception as e:
    print("Exception =", e)
    print("Exception Information= ", sys.exc_type, sys.exc_value)
    sys.exit(1)


  # All Went well - exiting!
  print("MyScript completed successfully!")
  sys.exit(0)

