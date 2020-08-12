
# ************************************************************************
# Script: GetOpenAPIJson.py
# Author: Richard KNechtel
# Date: 06/02/2020
# Description: This script is an example of using Python to process 
#              JSON data, URL's.
#
# Note: Must install Python libs: 
#       pip install urllib3
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
#   Args format from a DOS Batch file (using either python):
#   call python Drive:\Path\GetOpenAPIJson.py Param1 Param2
#
#   Args format from a Shell Script (using either python):
#   python /Path/GetOpenAPIJson.py Param1 Param2
#
#************************************************************************

#---------------------------------------------------------[Imports]------------------------------------------------------

_modules = [
            'argparse',
            'datetime',
            'errno',
            'io',
            'json',
            'logging',
            'os',
            'shutil',
            'sys',
            'time',
            'traceback',
            'urllib3',
           ]

for module in _modules:
  try:
    locals()[module] = __import__(module, {}, {}, [])
  except ImportError as ie:
    print("Error importing %s." % module)

	
# Custom Modules:
from modules import getopenapijsonconfig as config
from modules import genericfunctions as genfunc
from modules import jsonfunctions as jsonfunc


#---------------------------------------------------------[Script Parameters]------------------------------------------------------
print("")
print("Passed Arguments:")
print(sys.argv)
print("")

# Set our Variables:
Param1 = sys.argv[0]
Param2 = sys.argv[1]


#---------------------------------------------------------[Initialisations]--------------------------------------------------------

Username = os.environ["USERNAME"]

global GetOpenAPIJsonLogger

# For Info and up logging
config.LogLevel = logging.INFO
# For Debug and up Logging:
#config.LogLevel = logging.DEBUG

config.OutputFile = "C:\Temp"

# This is the JSON data (dictionary) returned from Swagger/OpenAPI
global JsonData

# This is the new Info Dictionary
global NewInfoDict

# Check values for looking if key exists
global CheckDict
global CheckKey
CheckDict = "info"
CheckKey = "title"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

#---------------------------------------------------------[Functions]--------------------------------------------------------


# ###################################################################################
# Function: InitGetOpenAPIJsonLogging
# Description:  Initialize the GetOpenAPIJson logging
# Parameters: None
#
def InitGetOpenAPIJsonLogging():
  # Initialize the default logging system:
  config.LogPath = "C:\Temp\Log"
  config.LogFile = "GetOpenAPIJson.log" 
  #print("Log File Name = " + os.path.join(config.LogPath, config.LogFile))
  
  # Check if Log directory exists, if it doens't create it
  DirExists = os.path.isdir(config.LogPath)
  if DirExists==False:
    try:
      os.mkdir(config.LogPath)
    except OSError:
      print("Creation of the directory %s failed" % config.LogPath)
    else:
      print("Successfully created the directory %s" % config.LogPath)    

  # For Info and up logging
  GetOpenAPIJsonLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),config.LogLevel)

  return GetOpenAPIJsonLogger

# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: Environment - This is the environment for URL 
#                           (options: dev, test, prepro, prod)
#             ApiName      - This is the Name of the API/Service
#
def ProcessParams(argv):
  # Set our Variables:

  # Check the total number of args passed - make sure we get 3 (2 + the script name that is passed by default).
  if(len(sys.argv) == 3):
    genfunc.ShowParams()
    config.ThisScript = sys.argv[0]
    #config.Environment = sys.argv[1]
    config.ApiName = sys.argv[1]
    config.JsonURL = sys.argv[2]

    # Verify we got values for parameters:
    if config.ApiName is None:
      GetOpenAPIJsonLogger.error("Paramater API Name is empty.")
      config.HasError = True
    else:
      config.HasError = False

    if config.JsonURL is None:
      GetOpenAPIJsonLogger.error("Paramater JSON URL is empty.")
      config.HasError = True
    else:
      config.HasError = False

    if config.HasError==True:
      config.ShowUsage()
      sys.exit(1)

  else:
    config.ShowUsage()
    sys.exit(1)

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
   
 
#-----------------------------------------------------------[Execution]------------------------------------------------------------

# ************************************
# Main Script Execution
# ************************************

# Will only run if this file is called as primary file 
if __name__ == '__main__':

  # Intialize variables:
  JsonResponse = ""

	# Initialize Logging:
  GetOpenAPIJsonLogger = InitGetOpenAPIJsonLogging()

  # Proccess Parameters
  ProcessParams(sys.argv)

  try:

    GetOpenAPIJsonLogger.info("Starting  GetOpenAPIJson script at " + genfunc.GetCurrentDateTime() + ".")
    GetOpenAPIJsonLogger.info("Parameters = " + str(sys.argv))

    # Create new info dictionary to update the JSON data with
    NewInfoDict = {'swagger':'2.0','info':{'title': config.ApiName, 'version': '1.0', 'termsOfService': 'http://mycompany.com', 'license': {'name': 'My Company License'}}}
    GetOpenAPIJsonLogger.info("NewInfoDict = " + str(NewInfoDict))

	  # Get JSON File/Data from URL
    GetOpenAPIJsonLogger.info("Url = " +  config.JsonURL)

    try:
      # Check if URL Passed is HTTP URL or File Path:
      isHttp = config.JsonURL.startswith('http')
      if isHttp:
        GetOpenAPIJsonLogger.info("Trying to get JSON from URL")
        JsonResponse = jsonfunc.GetJSONFromURL(GetOpenAPIJsonLogger, config.HasError, config.JsonURL)
        JsonData = json.loads(JsonResponse.data.decode('utf-8'))
      else:
        GetOpenAPIJsonLogger.info("Trying to get JSON from File")
        JsonData = jsonfunc.GetJsonFromFile(GetOpenAPIJsonLogger, config.HasError, config.JsonURL)

    except Exception as e:
      GetOpenAPIJsonLogger.error("GET URL Execution failed.")
      GetOpenAPIJsonLogger.error("Exception Information = " + traceback.format_exc())
      config.HasError = True

    if not config.HasError:
      # Get JSON Data
      Data = json.dumps(JsonData)
      GetOpenAPIJsonLogger.info("Data = " + Data)

      # Checks if a key exists in JSON Data
      KeyExists = jsonfunc.IsJsonKeyPresent(GetOpenAPIJsonLogger, JsonData, CheckDict, CheckKey)
      GetOpenAPIJsonLogger.info("Does Key: title Exist = " + str(KeyExists))
      if KeyExists:
        GetOpenAPIJsonLogger.info("API " + config.ApiName + " has the title property")

        # Write JSON To File
        WriteJsonToFile(config.OutputFile + "\\" + config.ApiName + "-api-docs-apache.json", JsonData)
      else:
        # info - tile is missing we need to add it for Azure API Management to import it
        GetOpenAPIJsonLogger.info("API " + config.ApiName + " does not have the title property")

        # This works for adding the title to the info section!
        GetOpenAPIJsonLogger.info("Updating jsonData")
        JsonData.update(NewInfoDict)
        GetOpenAPIJsonLogger.info("Updated Json Data = " + str(JsonData))

        # Write updated JSON to a file:
        JsonOutputFile = config.OutputFile + "\\" + config.ApiName + "-api-docs-apache.json"
        jsonfunc.WriteJsonToFile(GetOpenAPIJsonLogger, JsonOutputFile , JsonData)
      
        # Write pretty printed JSON to a File
        PrettyPrintFile = config.OutputFile + "\\" + config.ApiName + "-api-docs-apache-prettyprint.json"
        jsonfunc.PrettyPrintJsonToFile(GetOpenAPIJsonLogger,JsonData, PrettyPrintFile) 

    else:
      GetOpenAPIJsonLogger.error("GetOpenAPIJson Execution had failures.")
      raise Exception("GetOpenAPIJson Execution had failures.")

  except Exception as e:
    GetOpenAPIJsonLogger.info("GetOpenAPIJson script Ended at " + genfunc.GetCurrentDateTime() + ".")
    GetOpenAPIJsonLogger.error("Execution failed.")
    GetOpenAPIJsonLogger.error("Exception Information = " + traceback.format_exc())
    GetOpenAPIJsonLogger.error("")
    GetOpenAPIJsonLogger.error("GetOpenAPIJson.py completed unsuccessfully at " + genfunc.GetCurrentDateTime() + ".")
    config.HasError = True
    sys.exit(1)

  if not config.HasError:
    # All Went well - exiting!
    End_Time = time.time()
    GetOpenAPIJsonLogger.info("GetOpenAPIJson script Ended at " + genfunc.GetCurrentDateTime() + ".")
    GetOpenAPIJsonLogger.info("")
    GetOpenAPIJsonLogger.info("GetOpenAPIJson.py completed successfully at " + genfunc.GetCurrentDateTime() + ".")
    GetOpenAPIJsonLogger.info("")
    GetOpenAPIJsonLogger.info("========================================================")
    GetOpenAPIJsonLogger.info("")
    config.HasError = False
    sys.exit(0)
