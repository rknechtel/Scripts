
# ###################################################################################
# Script/module: modules\deployconfig.py
# Author: Richard Knechtel
# Date: 01/17/2018
# Description: This is a module of configurations for Deployment.py
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
global JbossHome
global Username
JbossHome = os.environ["JBOSS_HOME"]
Username = os.environ["USERNAME"]

# Parameters to Script:
global ThisScript
global Command
global Type
global Application
global AppSrv

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
  print("[USAGE]: Deployment.py arg1 arg2 arg3 arg4")
  print("arg1 = Command (deploy / undeploy / rollback)")
  print("arg2 = Type (hot / cold)")
  print("arg3 = Application (Example: MyApp.war)")
  print("arg4 = AppSrv Instance Name (Example: AppSrv01)")

  return



# This is a Function template:
# ###################################################################################
# Function: 
# Description:  
# Parameters: 
#
def MyFuncation(Param1, Param2):

  return