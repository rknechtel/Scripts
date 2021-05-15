# ###################################################################################
# Script/module: modules\MyScriptconfig.py
# Author: Richard Knechtel
# Date: 01/17/2018
# Description: This is a module of configurations for MyScriptconfig.py
# Python Version: 3.8.x
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

global Environment

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
  print("[USAGE]: MyScriptconfig.py arg1 arg2")
  print("arg1 = Param1 (Example: Some Paramaeter 1)")
  print("arg2 = Param2 (Example: Some Paramaeter 2)")

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