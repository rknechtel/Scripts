
# #!/usr/bin/python

# ************************************************************************
# Script: SearchGitRepos.py
# Author: Richard Knechtel
# Date: 04/10/2020
# Description: This script will Search across multiple Git repositores 
#
#  Based on articles by Alex Kras:
# https://www.alexkras.com/generate-weekly-reports-from-your-git-commits/
# https://www.alexkras.com/git-grep-multiple-repos-at-once/
#
# Also git repo cloner:
# https://metabroadcast.com/blog/how-to-grep-over-all-of-your-git-repos-or-finding-a-needle-in-a-haystack
# https://github.com/MartinsIrbe/git-repository-cloner
#
#
# Works:
# git grep -r "MYSearchTerm"
# git grep -n "MYSearchTerm"
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
#     call python C:\Scripts\Python\SearchGit\SearchGitRepos.py MySearchTem C:\Temp\GitRepos
#
#   Args format from a Shell Script (using python):
#     python /scripts/Python/SearchGitRepos.py MySearchTem C:\Temp\GitRepos
#
#
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

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
   except ImportError as ie:
     print("Error importing %s." % module)

# Custom Modules:
from modules import searchgitconfig as config 
from modules import genericfunctions as genfunc

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

print("")
print("Passed Arguments:")
print(sys.argv)
print("")

# Set our Variables:
#config.ThisScript = sys.argv[0]
#config.SearchParam = sys.argv[1]
#config.SearchPath = sys.argv[2]

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# For Info and up logging
config.LogLevel = logging.INFO
# For Debug and up Logging:
#config.LogLevel = logging.DEBUG

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

#---------------------------------------------------------[Functions]--------------------------------------------------------

####################################################################################
# Function: InitGitSearchLogging(0
# Description:  Initialize the Git Search Scripts logging 
# Parameters: None 
# 
def InitGitSearchLogging():
  # Initialize the default logging system:
  config.LogPath = "C:\Temp\Log"
  config.LogFile =  "GitSearch.log"
  #print("Log File Name = " + os.path.join(config.LogPath, config.LogFile))

  GitSearchLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),config.LogLevel)

  return GitSearchLogger


####################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: SearchTerm - Term to Search Git Repos for
#             SearchPath - Location of Git Repos to Search
#
def ProcessParams(argv):
  # Set our Variables:
  # Check the total number of args passed - make sure we get 2 
  # (1 + the script name that is passed by default).
  if(len(sys.argv) == 3):
    genfunc.ShowParams()
    config.ThisScript = sys.argv[0]
    config.SearchParam = sys.argv[1]
    config.SearchPath = sys.argv[2]
  else:
    config.ShowUsage()
    sys.exit(1)

  return

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# ************************************
# Main Script Execution
# ************************************

# Will only run if this file is called as primary file 
if __name__ == '__main__':

   ProcessParams(sys.argv)

   # Initialize Logging:
   GitSearchLogger = InitGitSearchLogging()

   GitSearchLogger.info("Starting SearchGitRepos script at " +  genfunc.GetCurrentDateTime() + ".")
   GitSearchLogger.info("Parameters = " + str(sys.argv))
   GitSearchLogger.info("SearchPath = " + config.SearchPath)
   GitSearchLogger.info("Getting list of repos")

   repos = os.listdir(config.SearchPath)
   repos = [os.path.join(config.SearchPath, repo) for repo in repos]

   GitSearchLogger.info("repos = " + str(repos))


   try:
     # Start Main execution here:
     results = ""
     
     outputfile = config.LogPath + "\\" + 'SearchGitResults.txt'
     config.SearchGitResults =  open(outputfile, 'a')

     GitSearchLogger.info("Searching over Repos")
     for repo in repos:
       #command = "cd {} && git grep --color=\"always\" \"{}\"".format(repo, config.SearchParam)
       command = "cd {} && git grep --color=\"never\" \"{}\"".format(repo, config.SearchParam)
       #GitSearchLogger.info("command = " + command)
       results = subprocess.run(command, shell=True, capture_output=True)
       results = results.stdout.decode("utf-8", 'ignore')
       if(len(results) > 0 and "Not a directory" not in results and "Not a git repository" not in results):
         GitSearchLogger.info("\n" + os.path.relpath(repo, config.SearchPath))
         results = repo + " - " + results
         GitSearchLogger.info("results = " + results)
         GitSearchLogger.error("")
         
         # Write Search Results to File:
         config.SearchGitResults.write(results + '\n')
  
   except Exception as e:
     GitSearchLogger.info("SearchGitRepos script Ended at " + genfunc.GetCurrentDateTime() + ".")
     GitSearchLogger.error("Execution failed.")
     GitSearchLogger.error("Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
     GitSearchLogger.error("")
     GitSearchLogger.error("SearchGitRepos.py completed unsuccessfully at " + genfunc.GetCurrentDateTime() + ".")
     config.HasError = True
     sys.exit(1)

   finally:
     # Flush and Close file
     GitSearchLogger.info("Closing File Output")
     config.SearchGitResults.flush()
     config.SearchGitResults.close()

   if config.HasError==False:
     # All Went well - exiting!
     GitSearchLogger.info("SearchGitRepos script Ended at " + genfunc.GetCurrentDateTime() + ".")
     GitSearchLogger.info("")
     GitSearchLogger.info("SearchGitRepos.py completed successfully at " + genfunc.GetCurrentDateTime() + ".")
     GitSearchLogger.info("")
     GitSearchLogger.info("========================================================")
     GitSearchLogger.info("")
     config.HasError = False
     sys.exit(0)

# End of SearchGitRepos.py