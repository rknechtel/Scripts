# *********************************************************************************************
# Script: WinService.py
# Author: Richard Knechtel
# Date: 09/13/2018
# Description: This script will handle working with Windows Services.
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
#     Args format from a DOS Batch file (using either python or jython):
#     call python D:\opt\Wildfly\usrbin\Python\WinService.py WF10APPSRV01
#     call jython D:\opt\Wildfly\usrbin\Python\WinService.py WF10APPSRV01
# 
#     Args format from a Shell Script (using either python or jython):
#     python /opt/Wildfly/usrbin/Python/WinService.py WF10APPSRV01
#     jython /opt/Wildfly/usrbin/Python/WinService.py WF10APPSRV01
#
#*************************************-*******************************************************

# ---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'psutil',
            'sys',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)

# Custom Modules:
from modules import genericfunctions as genfunc



# ---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Get environment variables:
ServiceName = 'empty'
ThisScript = 'WinService.py'

# ----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

# ---------------------------------------------------------[Functions]--------------------------------------------------------
# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: Windows Service
#
def ProcessParams(argv):
  # Set our Variables:
  global ServiceName
  global ThisScript

  # Check the total number of args passed - make sure we get 5 (4 + the script name that is passed by default).
  if(len(sys.argv) == 2):
    ShowParams()
    ThisScript = sys.argv[0]
    ServiceName = sys.argv[1]
  else:
    ShowUsage()
    sys.exit(1)

  return


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
# Function: ShowUsage
# Description:  Shows the Usage if no parameters
# Parameters: None
#
def ShowUsage():
  print("[USAGE]: WinService.py arg1")
  print("arg1 = WindowsServiceName (Example: WF10APPSRV01")

  return


# ###################################################################################
# Function: getService
# Description:  Gets a Windows Service
# Parameters: Windows Service Name
#
def getService(name):

        service = None
        try:
            service = psutil.win_service_get(name)
            service = service.as_dict()
        except Exception as ex:
            print( str(ex))

        return service

# -----------------------------------------------------------[Execution]------------------------------------------------------------

# ************************************
# Main Script Execution
# 

# Will only run if this file is called as primary file 
if __name__ == '__main__':
  
  ProcessParams(sys.argv)
  
  service = getService(ServiceName)

  print(service)

  if service:
    print("service found")
  else:
    print("service not found")


  if service and service['status'] == 'running' :
    print("service is running")
  else :
    print( "service is not running")
