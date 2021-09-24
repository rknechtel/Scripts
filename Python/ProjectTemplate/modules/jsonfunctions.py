
# ###################################################################################
# Script/module: modules\jsonfunctions.py
# Author: Richard Knechtel
# Date: 06/09/2020
# Description: This is a module of JSON functions
#
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
# Ref:
# https://raw.githubusercontent.com/rknechtel/Scripts/master/Python/GetOpenAPIJson/modules/jsonfunctions.py
#
# ###################################################################################
from _overlapped import NULL


# ---------------------------------------------------------[Imports]------------------------------------------------------

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
  except ImportError:
    print("Error importing %s." % module)

# Custom Modules:
from modules import genericfunctions as genfunc

# ---------------------------------------------------------[Initialisations]--------------------------------------------------------

global JsonFuncLogger

# This is the JSON data (dictionary) returned from Swagger/OpenAPI
global JsonData

# This is the new Info Dictionary
global NewInfoDict

# ---------------------------------------------------------[Functions]----------------------------------------------------
  
 ####################################################################################
# Function: GetJSONFromURL
# Description: Will get JSON data from a URL 
# Parameters: Logger
#             HasError
#             JSON URL
# Example Call:
# GetJSONFromURL(URL)
#
def GetJSONFromURL(pLogger, pHasError, pUrl):
  JsonResponse = ''
  try:
    # Using urllib3:
    #conretry = urllib3.util.Retry(total=10, read=10, connect=10, backoff_factor=1)
    # Retry Params:
    # Number of Retries
    # How many times to retry on read errors
    # How many connection-related errors to retry on
    # A backoff factor to apply between attempts after the second try (how long to sleep)
    # Ref: https://urllib3.readthedocs.io/en/latest/reference/urllib3.util.html
    #contimeout = urllib3.util.Timeout(connect=2.0, read=4.0)
    # Timeout Params:
    # The maximum amount of time (in seconds) to wait for a connection attempt to a server to succeed.
    # The maximum amount of time (in seconds) to wait between consecutive read operations for a response from the server. 
    # Ref: https://urllib3.readthedocs.io/en/latest/reference/urllib3.util.html
    #Http = urllib3.PoolManager(retry=conretry, timeout=contimeout, maxsize=1)
    Http = urllib3.PoolManager()
    #JsonResponse = Http.request('GET', pUrl)
    JsonResponse = Http.request('GET', pUrl, retries=30)
    pLogger.info("JsonResponse = " + str(JsonResponse.data.decode('utf-8')))
    pHasError = False

  except urllib3.exceptions.NewConnectionError as nce:
    pHasError = True
    pLogger.error("GetJSONFromURL Connection Error (Connection Refused or Get Address Information Error) - Exception Information = " + traceback.format_exc())
  except urllib3.exceptions.MaxRetryError as mre:
    pHasError = True
    pLogger.error("GetJSONFromURL Max Retries hit - Exception Information = " + traceback.format_exc())
  except Exception as e:
    pHasError = True
    pLogger.error("GetJSONFromURL - Exception Information = " + traceback.format_exc())

  return JsonResponse

####################################################################################
# Function: GetJsonFromFile
# Description: Read JSON Data from a File 
# Parameters: Logger
#             HasError
#             JSON Full File Path 
# Example Call:
# GetJsonFromFile(C:\Temp\MyFile.json)
#
def GetJsonFromFile(pLogger, pHasError, pJsonFile):
  JsonData = ''

  try:
    with open(pJsonFile, 'r') as jsonFile:
      JsonData = json.load(jsonFile)
      pJsonFile = False

  except Exception as e:
    pJsonFile = True
    pLogger.error("GetJsonFromFile - Exception Information = " + traceback.format_exc())

  return JsonData

####################################################################################
# Function: RecursivelyParseJson
# Description: Recursively Parse a JSON object and print it out 
# Parameters: Logger
#             JSON Data (Dictionary) 
#             
# Example Call:
# RecursivelyParseJson(JsonData)
#
def RecursivelyParseJson(pLogger, pJsonData):
   try:
     for key,value in pJsonData.items():
       if isinstance(value, dict):
         RecursivelyParseJson(value)
       else:
         pLogger.info(str(key) + ":" + str(value))

   except Exception as e:
     pLogger.error("RecursivelyParseJson - Exception Information = " + traceback.format_exc())

   return


####################################################################################
# Function: IsJsonKeyPresent
# Description: Checks if a key exists in JSON Data # Parameters: JSON Data Dict
#             Key to look for
# Parameters: Logger
#             JsonData
#             Dictionary
#             Key
#
# Returns: True or False
#
def IsJsonKeyPresent(pLogger, pJsonData, pDict, pKey):
   try:
     InfoObject = pJsonData[pDict]
     pLogger.info("IsJsonKeyPresent: InfoObject = " + str(InfoObject))
     buf = InfoObject[pKey]
   except KeyError:
     return False

   return True


####################################################################################
# Function: WriteJsonToFile
# Description: Will write JSON data to a file 
# Parameters: Logger
#             Full Path and File Name
#             JSON Data (Dictionary)
# Example Call:
# WriteJsonToFile("C:\Temp\data_file.json", Data)
#
def WriteJsonToFile(pLogger, pFilePath, pJsonData):

  pLogger.info("WriteJsonToFile: File Path = " + pFilePath)
  pLogger.info("WriteJsonToFile: JSON Data = " + str(pJsonData))
  try:
    with open(pFilePath, "w") as write_file:
      json.dump(pJsonData, write_file)

  except Exception as e:
    pLogger.error("WriteJsonToFile - Exception Information = " + traceback.format_exc())

  return


# ###################################################################################
# Function: PrettyPrintJson
# Description: This will Pretty Print (format) JSOn data
# Parameters: Logger
#             JSON Data (Dictionary)
# Exapmle Call:
# PrettyPrintJson(JsonData)
#
def PrettyPrintJson(pLogger, pJsonData):

  # Initialize
  PrettPrint = ''

  try:
    # Pretty Printing JSON string
    PrettPrint = json.dumps(pJsonData, indent = 4, sort_keys=True)
    pLogger.info("PrettyPrintJson: PrettyPrint = \n" + PrettPrint)

  except Exception as e:
     pLogger.error("PrettyPrintJson - Exception Information = " + traceback.format_exc())

  return PrettPrint

# ###################################################################################
# Function: PrettyPrintJsonToFile
# Description: This will Pretty Print (format) JSOn data and write it to a file
# Parameters: Logger
#             JSON Data (Dictionary)            
#             Full Path and File Name
#             
# Exapmle Call:
# PrettyPrintJsonToFile(Logger,JsonData, C:\Temp\PrettyPrintFile.json)
#
def PrettyPrintJsonToFile(pLogger, pJsonData, pJsonFilePath):

  # Initialize
  PrettPrint = ''

  try:
    # Pretty Printing JSON string
    PrettPrint = json.dumps(pJsonData, indent = 4, sort_keys=True)
    PrettyPrintedJsonFile = open(pJsonFilePath, "w")
    PrettyPrintedJsonFile.write(PrettPrint)
    PrettyPrintedJsonFile.close()

  except Exception as e:
     pLogger.error("PrettyPrintJsonToFile - Exception Information = " + traceback.format_exc())

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
