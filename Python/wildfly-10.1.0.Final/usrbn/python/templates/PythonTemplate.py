# ************************************************************************
# Script: <Script>.py
# Author: <Name>
# Date: <Date>
# Description: This script will ....
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
#  <Examples on how to call Script>  
# 
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

import argparse
import logging
import sys
import time

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
print("")
print("Passed Arguments:")
print(sys.argv)
print("")

# Set our Variables:
ThisScript = sys.argv[0]

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Example getting an environment variable:
MyVariable = os.environ["MY_VARIABLE"]


#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

#---------------------------------------------------------[Functions]--------------------------------------------------------

# ###################################################################################
# Function: InitLogging
# Description:  Initialize logging
# Parameters: 
#
def InitiLogging(Loglevel):
  logging.basicConfig(format="%(levelname)s: %(message)s", level=Loglevel)

  return


# ###################################################################################
# Function: 
# Description:  
# Parameters: 
#
def MyFuncation(Param1, Param2):

  return


   
def main(argv):
  # check arguments and options
  parser = argparse.ArgumentParser(description='Description of your program')
  parser.add_argument('-f','--foo', help='Description for foo argument', required=True)
  parser.add_argument('-b','--bar', help='Description for bar argument', required=True)
  args = vars(parser.parse_args())
  
  if args['foo'] == 'Hello':
    # code here
    print("doing something")

  if args['bar'] == 'World':
    # code here
    print("doing something")

# Will only run if this file is called as primary file
if __name__ == "__main__":
    main()

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start_Time = time.time()
print("Starting <Your Script Name here> script at" + Start_Time + ".")

  
try:
  # Start Main execution here:
  print("Doing something.")
  


except Exception as e:
  print("Execution failed.")
  print("Exception =", e)
  print("Exception Information= ", sys.exc_type, sys.exc_value)
  sys.exit(1)


# All Went well - exiting!
End_Time = time.time()
print("<Your Script Name Here> completed successfully!")
sys.exit(0)

