
# ###################################################################################
# Script/module: modules\gitcloneconfig.py
# Author: Richard Knechtel
# Date: 04/10/2020
# Description: This is a module of configurations for GitRepoCloner.py
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
            'sqlite3',
            'time',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError:
    print("Error importing %s." % module)

# ---------------------------------------------------------[Initialisations]--------------------------------------------------------

# Get environment variables:


# Parameters to Script:
global ThisScript
global GtiCommand
global database
global GitRepoDir

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
  print("[USAGE]: GitRepoCloner.py arg1 arg2 arg3")
  print("arg1 = command (Example: clone or pull)")
  print("arg2 = SQLite DB (Example: D:\DBs\MySQLiteDB.s3db)")
  print("arg3 = Git Repo Clone Diretory (Example: D:\CloneDir)")

  return


 
# ###################################################################################
# Function: create_sqlite_connection
# Description:  Creates SQLite Database Connection 
# Parameters: SQLite database File
#
def create_sqlite_connection(db_file):
    # create a database connection to the SQLite database specified by the db_file
    # :param db_file: database file
    # :return: Connection object or None
 
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as e:
        print(e)

    return conn
 
 

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

