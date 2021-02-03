
# ###################################################################################
# Script/module: modules\winsrvadminconfig.py
# Author: Richard Knechtel
# Date: 02/20/2020
# Description: This is a module of configurations for WinServiceAdmin.py
#
#
# LICENSE:
# This script is in the public domain, free from copyrights or restrictions.
#
# ###################################################################################

# ---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'datetime',
            'os',
            'sys',
            'time',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)

# ---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Set environment variables:
os.putenv("NOPAUSE", "true")

# Get environment variables:
global WinTemp
global Username
WinTemp ="D:\Temp"
Username = os.environ["USERNAME"]
global ValidCommands
ValidCommands = ['stop','start','status']

# Parameters to Script:
global ThisScript
global Command
global Service
global Server
global ServiceLocation

# Logging:
global LogPath
global LogFile

# Errors
global HasError
HasError = False

# ---------------------------------------------------------[Functions]----------------------------------------------------


# ###################################################################################
# Function: ShowUsage
# Description:  Shows the Usage if no parameters
# Parameters: None
#
def ShowUsage():
  print("[USAGE]: WinServiceAdmin.py arg1 arg2 arg3 arg4")
  print("arg1 = Service Command (Stop/Start/Restart/Suspend/Resume)")
  print("arg2 = Service Name (Example: AppSrv01")
  print("arg3 = Server Name (Example: mc21dwin235")
  print("arg4 = Service Locaton (Values: local/remote)")

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