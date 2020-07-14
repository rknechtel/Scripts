# ###################################################################################
# Script/module: modules\getopenapijsonconfig.py
# Author: Richard Knechtel
# Date: 04/10/2020
# Description: This is a module of configurations for GetOpenAPIJson.py
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

# Get environment variables:
global BASEDIR

# Parameters to Script:
global ThisScript
#global Environment
global ApiName
global JsonURL

global OutputFile

# Logging:
global LogPath
global LogFile
global LogLevel

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
  print("[USAGE]: GetOpenAPIJson.py arg1 arg2")
  print("arg1 = API Name (Example: My-Service)")
  print("arg2 = JSON URL (Example: https://devapachea.mycompany.com/my-service/v2/api-docs?group=public-api)")
  print("NOTE: arg2 must be enclosed in single then double quotes")

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