
# *********************************************************************************************
# Script: WinServiceAdmin.py
# Author: Richard Knechtel
# Date: 02/24/2020
# Description: This script will handle Working with Windows Services
# Version: 1.0
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# EXIT STATUS:
#     Exit codes:
#     0 = Success
#     1 = Error
#
# EXAMPLES
# 
#     Args format from a DOS Batch file (using either python):
#     call python D:\opt\Scripts\Python\WinServiceAdmin.py stop MyWindowsService MyWindowsServer local
# 
#     Args format from a Shell Script (using either python):
#     python /opt/Scripts/Python/WinServiceAdmin.py stop MyWindowsService MyWindowsServer local
#
#*************************************-*******************************************************


# ---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'argparse',
            'datetime',
            'errno',
            'logging',
            'os',
            'shutil',
            'subprocess',
            'sys',
            'time',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)

# Custom Modules:
from modules import winsrvadminconfig as config
from modules import genericfunctions as genfunc
from modules import windowsfunctions as winfunc


# ---------------------------------------------------------[Initialisations]--------------------------------------------------------


# ----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

# ---------------------------------------------------------[Functions]--------------------------------------------------------

# ###################################################################################
# Function: InitWinServiceAdminLogging(0
# Description:  Initialize the Delpoyment Scripts logging
# Parameters: None
#
def InitWinServiceAdminLogging():
  # Initialize the default logging system:
  config.LogPath = config.WinTemp
  config.LogFile = "WinServiceAdmin.log" 
  #print("Log File Name = " + os.path.join(config.LogPath, config.LogFile))
  
  # For Debug and up Logging:
  #WinServiceAdminLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),logging.DEBUG)
  # For Info and up logging
  WinServiceAdminLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),logging.INFO)

  return WinServiceAdminLogger

# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: Command           - stop/start/status
#             Service           - Name of Windows Service
#             Server            - Name of Server
#             ServiceLocation   - Service Location (local or remote)
#
def ProcessParams(argv):
  # Set our Variables:

  # Check the total number of args passed - make sure we get 5 (4 + the script name that is passed by default).
  if(len(sys.argv) == 5):
    genfunc.ShowParams()
    config.ThisScript = sys.argv[0]
    config.Command =sys.argv[1]
    config.Service = sys.argv[2]
    config.Server = sys.argv[3]
    config.ServiceLocation = sys.argv[4]
  else:
    config.ShowUsage()
    sys.exit(1)

  return


# -----------------------------------------------------------[Execution]------------------------------------------------------------

# ************************************
# Main Script Execution
# ************************************

# Will only run if this file is called as primary file 
if __name__ == '__main__':
  
  ProcessParams(sys.argv)
  
  # Initialize Logging:
  WinServiceAdminLogger = InitWinServiceAdminLogging()

  WinServiceAdminLogger.info("")
  WinServiceAdminLogger.info("Parameters = " + str(sys.argv))
  #WinServiceAdminLogger.debug("RSK Debug> In main - Parameters = " + config.Command + " " + config.Service + " " + config.Server + " " + config.ServiceLocation)
  WinServiceAdminLogger.info("")
  WinServiceAdminLogger.info("LogFile = " + os.path.join(config.LogPath, config.LogFile))
  WinServiceAdminLogger.info("")
  WinServiceAdminLogger.info("Starting WinServiceAdmin.py script at " + genfunc.GetCurrentDateTime() + ".")
  WinServiceAdminLogger.info("")
  WinServiceAdminLogger.info("Running as user: " + config.Username)
  WinServiceAdminLogger.info("")

  try:
    # Start Main execution here:
    WinServiceAdminLogger.info("Starting WinServiceAdmin.")

    # *** Verify command is one of the valid commands (stop/start/status) *********************
    #config.Command = 'restart'
    WinServiceAdminLogger.info("Passed Command = " + config.Command)

    WinServiceAdminLogger.info("Valid Commands = " + str(config.ValidCommands))
    WinServiceAdminLogger.info("Check if " + config.Command + " is in the ValidCommands list")
 
    if config.Command not in config.ValidCommands :
      WinServiceAdminLogger.error(config.ThisScript + " had an error - command not valid - command given = " + config.Command + " - valid commands are (stop/start/status).")
      config.HasError = True

    # We got a valid Windows Service Command
    #
    WinServiceAdminLogger.info("Is there and error? " + str(config.HasError))
    if config.HasError==False :

      # ***** Run Windows Service Manager Local ****************************** 
      # 
      if config.ServiceLocation=="local" :
        try:
          # Run the Windows Service Command:
          winfunc.windows_service_manager_local(config.Command, config.Server, config.Service, WinServiceAdminLogger)

        except Exception as e:
          # sys.exc_info() returns a tuple with three values (type, value, traceback)
          e_type, e_value, e_traceback = sys.exc_info()
          #e_valuea, e_valueb, e_valuec = e_value
          WinServiceAdminLogger.error("windows_service_manager_local failed.")
          WinServiceAdminLogger.error("Error = " + str(e_value))
          WinServiceAdminLogger.error("Exception Information:")
          WinServiceAdminLogger.error("Exception Type = " + str(e_type))
          #WinServiceAdminLogger.error("Exception Value = " + e_valuea + " " + e_valueb + " " + e_valuec)
          WinServiceAdminLogger.error("Exception Value = " + str(e_value))
          WinServiceAdminLogger.error("Exception Traceback = ", e_traceback)
          config.HasError = True
          raise Exception(e)
    
      # ***** Run Windows Service Manager Remote ******************************
      # 
      elif config.ServiceLocation== "remote" :
        try:
          # Run the Windows Service Command:
          winfunc.windows_service_manager_remote(config.Command, config.Server, config.Service, WinServiceAdminLogger)
		  
        except Exception as e:
          # sys.exc_info() returns a tuple with three values (type, value, traceback)
          e_type, e_value, e_traceback = sys.exc_info()
          #e_valuea, e_valueb, e_valuec = e_value
          WinServiceAdminLogger.error("windows_service_manager_remote failed.")
          WinServiceAdminLogger.error("Error = " + str(e_value))
          WinServiceAdminLogger.error("Exception Information:")
          WinServiceAdminLogger.error("Exception Type = " + str(e_type))
          #WinServiceAdminLogger.error("Exception Value = " + e_valuea + " " + e_valueb + " " + e_valuec)
          WinServiceAdminLogger.error("Exception Value = " + str(e_value))
          WinServiceAdminLogger.error("Exception Traceback = ", e_traceback)
          config.HasError = True
          raise Exception(e)

    # ******************************************************
    # If we had an error anywhere above throw an exception:
    if config.HasError == True:
      raise Exception("There was an Exception in " + config.ThisScript + " please see errors generated in log file " + os.path.join(config.LogPath, config.LogFile))
 
  except Exception as e:
    # sys.exc_info() returns a tuple with three values (type, value, traceback)
    e_type, e_value, e_traceback = sys.exc_info()
    #e_valuea, e_valueb, e_valuec = e_value
    WinServiceAdminLogger.error("Execution failed.")
    WinServiceAdminLogger.error("Error = " + str(e_value))
    WinServiceAdminLogger.error("Exception Information:")
    WinServiceAdminLogger.error("Exception Type = " + str(e_type))
    #WinServiceAdminLogger.error("Exception Value = " + e_valuea + " " + e_valueb + " " + e_valuec)
    WinServiceAdminLogger.error("Exception Value = " + str(e_value))
    WinServiceAdminLogger.error("Exception Traceback = ", e_traceback)
    WinServiceAdminLogger.error("")
    WinServiceAdminLogger.error("WinServiceAdmin.py completed unsuccessfully at " + genfunc.GetCurrentDateTime() + ".")
    config.HasError = True
    sys.exit(1)

  if config.HasError==False:
    # All Went well - exiting!
    WinServiceAdminLogger.info("")
    WinServiceAdminLogger.info("WinServiceAdmin.py completed successfully at " + genfunc.GetCurrentDateTime() + ".")
    WinServiceAdminLogger.info("")
    WinServiceAdminLogger.info("")
    WinServiceAdminLogger.info("========================================================")
    WinServiceAdminLogger.info("")
    WinServiceAdminLogger.info("")
    config.HasError = False
    sys.exit(0)


# -----------------------------------------------------------[End Execution]--------------------------------------------------------
