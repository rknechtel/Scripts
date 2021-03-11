####################################################################################
# Script/module: modules\searchgitconfig.py 
# Author: Richard Knechtel 
# Date: 04/10/2020 
# Description: This is a module of configurations for SearchGitRepos.py 
#  
# LICENSE:
# This script is in the public domain, free from copyrights or restrictions.
#
#
###################################################################################


#---------------------------------------------------------[Imports]------------------------------------------------------

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

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Get environment variables:

# Parameters to Script:
global ThisScript
global SearchTerm
global SearchPath
global SearchGitResults

# Logging:
global LogPath
global LogFile
global LogLevel

# Errors
global HasError
HasError = False


#---------------------------------------------------------[Functions]----------------------------------------------------


####################################################################################
# Function: ShowUsage
# Description:  Shows the Usage if no parameters # Parameters: None 
# 
def ShowUsage():
  print("[USAGE]: SearchGitRepos.py arg1 arg2")
  print("arg1 = Term To Search For (Example: MySearchTerm)")
  print("arg1 = Search Path (Example: D;\Temp\GitRepos)")

  return



# This is a Function template:
####################################################################################
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