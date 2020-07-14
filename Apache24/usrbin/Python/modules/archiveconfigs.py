# ###################################################################################
# Script/module: modules\archiveconfigs.py
# Author: Richard Knechtel
# Date: 10/31/2018
# Description: This is a module of configurations for ArchiveApacheLogs.py
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
global ApacheHome
global Username
ApacheHome = os.environ["HTTP_HOME"]
Username = os.environ["USERNAME"]

# Parameters to Script:
global ThisScript
global RestartApache
global PurgeDays


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
  print("[USAGE]: ArchiveApacheLogs.py arg1 arg2")
  print("arg1 = Restart Apache (Example: no)")
  print("arg2 = PurgeDays (Optional) = Days Older than to Purge (Example: 30)")
  print("       Note: This will purge any logs older than 30 days.)")

  return



# This is a Function template:
# ###################################################################################
# Function: 
# Description:  
# Parameters: 
#
def MyFuncation(Param1, Param2):

  return


