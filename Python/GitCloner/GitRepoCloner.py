# #!/usr/bin/python

# ************************************************************************
# Script: GitRepoCloner.py
# Author: Richard Knechtel
# Date: 94.16.2929
# Description: This script will Clone Many Git Repos
# Version: 1.0
# 
# Note: Requires Python SQLite library
# pip install pysqlite
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# EXIT STATUS:
#     Exit codes:
#     0 = Success
#     1 = Error
#
# EXAMPLES:
#   Args format from a DOS Batch file (using python):
#     call python C:\Scripts\Python\SearchGit\GitRepoCloner.py clone "C:\Scripts\Python\SearchGit\sqlitedb\GitRepos.s3db" "D:\GitClonedRepos"
#
#   Args format from a Shell Script (using python):
#     python /scripts/Python/GitRepoCloner.py clone "C:\Scripts\Python\SearchGit\sqlitedb\GitRepos.s3db" "D:\GitClonedRepos"
# 
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'argparse',
            'logging',
            'os',
            'sqlite3',
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
from modules import gitcloneconfig as config
from modules import genericfunctions as genfunc

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

print("")
print("Passed Arguments:")
print(sys.argv)
print("")

# Set our Variables:
#config.ThisScript = sys.argv[0]
#config.GtiCommand = sys.argv[1]
#config.database = sys.argv[2]
#config.GitRepoDir = sys.argv[3]

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

# For Info and up logging
config.LogLevel = logging.INFO
# For Debug and up Logging:
#config.LogLevel = logging.DEBUG

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

#---------------------------------------------------------[Functions]--------------------------------------------------------

# ###################################################################################
# Function: InitGitCloneLogging
# Description:  Initialize the Git Search Scripts logging
# Parameters: None
#
def InitGitCloneLogging():
  # Initialize the default logging system:
  config.LogPath = "C:\Temp"
  config.LogFile =  "GitRepoCloner.log"
  
  print("Log File Name = " + os.path.join(config.LogPath, config.LogFile))

  GitCloneLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),config.LogLevel)

  return GitCloneLogger

# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: SearchTerm  - Term to Search Git Repos for
#
def ProcessParams(argv):
  # Set our Variables:
  # Check the total number of args passed - make sure we get 5 (4 + the script name that is passed by default).
  if(len(sys.argv) == 4):
    genfunc.ShowParams()
    config.ThisScript = sys.argv[0]
    config.GtiCommand = sys.argv[1]
    config.database = sys.argv[2]
    config.GitRepoDir = sys.argv[3]
  else:
    config.ShowUsage()
    sys.exit(1)

  return

#-----------------------------------------------------------[Execution]------------------------------------------------------------

GitCloneLogger = None
conn = None

try:

  # Will only run if this file is called as primary file
  if __name__ == '__main__':

    # Start Main execution here:
    ProcessParams(sys.argv)

    # Initialize Logging:
    GitCloneLogger = InitGitCloneLogging()
  
    GitCloneLogger.info("Starting GitRepoCloner.py script at " + genfunc.GetCurrentDateTime() + ".")
    GitCloneLogger.info("")
    GitCloneLogger.info("Parameters = " + str(sys.argv))
  
    # Create a SQL connection to SQLite database
    GitCloneLogger.info("Connecting to SQLite Database " + config.database)
    conn = config.create_sqlite_connection(config.database)
    GitCloneLogger.info("Connected to SQLite Database " + config.database)
    cur = conn.cursor()

    SqlString='SELECT RepoUrl, ProjectName FROM Repos;'
    GitCloneLogger.info("Sql = " + SqlString)
    GitCloneLogger.info("Executing SQL")
    cur.execute(SqlString)

    GitCloneLogger.info("Fetching Rows")
    rows = cur.fetchall()

    GitCloneLogger.info("Looping over Rows")
    for row in rows:

      GitCloneLogger.info("row = " + str(row))
      
      if config.GtiCommand.lower() == 'clone':
        GitCloneLogger.info("Running Git Clone")
        config.command = "git clone \"{}\" \"{}\"".format(row[0], (config.GitRepoDir + "\\" + row[1]))
        GitCloneLogger.info("command = " + config.command)      
        subprocess.run(config.command, shell=True, capture_output=False)

      if config.GtiCommand.lower() == 'pull':
        GitCloneLogger.info("Running Git Pull")
        config.command = "git -C {} pull".format((config.GitRepoDir + "\\" + row[1]))
        GitCloneLogger.info("command = " + config.command)
        subprocess.run(config.command, shell=True, capture_output=False)

except sqlite3.Error as sqle:
    GitCloneLogger.error("SQLite Execution failed.")
    GitCloneLogger.error("Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
    GitCloneLogger.error("")
    GitCloneLogger.error("GitRepoCloner.py completed unsuccessfully at " + genfunc.GetCurrentDateTime() + ".")
    config.HasError = True
    sys.exit(1)

except Exception as e:
    GitCloneLogger.error("Execution failed.")
    GitCloneLogger.error("Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
    GitCloneLogger.error("")
    GitCloneLogger.error("GitRepoCloner.py completed unsuccessfully at " + genfunc.GetCurrentDateTime() + ".")
    config.HasError = True
    sys.exit(1)


finally:
    # Close the connection
    conn.close()

if config.HasError==False:
    # All Went well - exiting!
    GitCloneLogger.info("")
    GitCloneLogger.info("GitRepoCloner.py completed successfully at " + genfunc.GetCurrentDateTime() + ".")
    GitCloneLogger.info("")
    GitCloneLogger.info("========================================================")
    GitCloneLogger.info("")
    config.HasError = False
    sys.exit(0)

# End of GitRepoCloner.py
