# *********************************************************************************************
# Script: Deployment.py
# Author: Richard Knechtel
# Date: 01/09/2018
# Description: This script will handle deployments and undeployments and 
#              rollbacks
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
# 
#     Args format from a DOS Batch file (using either python or jython):
#     call python D:\opt\Wildfly\usrbin\Python\Deployment.py deploy hot MyApp.war AppSrv01
#     call jython D:\opt\Wildfly\usrbin\Python\Deployment.py deploy hot MyApp.war AppSrv01
# 
#     Args format from a Shell Script (using either python or jython):
#     python /opt/Wildfly/usrbin/Python/Deployment.py deploy hot MyApp.war AppSrv01
#     jython /opt/Wildfly/usrbin/Python/Deployment.py deploy hot MyApp.war AppSrv01
#
#*************************************-*******************************************************


# ---------------------------------------------------------[Imports]------------------------------------------------------

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
  except ImportError:
    print("Error importing %s." % module)
    

# Custom Modules:
from modules import delpoyconfig as config 
from modules import genericfunctions as genfunc


# ---------------------------------------------------------[Initialisations]--------------------------------------------------------


# ----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
ScriptVersion = '1.0'

# ---------------------------------------------------------[Functions]--------------------------------------------------------

# ###################################################################################
# Function: InitDeploymentLogging(0
# Description:  Initialize the Delpoyment Scripts logging
# Parameters: None
#
def InitDeploymentLogging():
  # Initialize the default logging system:
  config.LogPath = os.path.join(os.path.join(config.JbossHome, config.AppSrv), "log")
  config.LogFile = config.AppSrv + "Deployment.log" 
  #print("Log File Name = " + os.path.join(config.LogPath, config.LogFile))
  
  # For Debug and up Logging:
  #DeployLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),logging.DEBUG)
  # For Info and up logging
  DeployLogger = genfunc.CreateLogger(__name__, os.path.join(config.LogPath, config.LogFile),logging.INFO)

  return DeployLogger

# ###################################################################################
# Function: ProcessParams
# Description:  This will process any parameters to the Script
# Parameters: Command      - deploy/undeploy/rollback
#             Type         - hot/cold (deploy) 
#             Application  - full application with extension (Example: MyApp.war)
#             AppSrv       - AppSrv instance to deploy to (Example: AppSrv01)
#
def ProcessParams(argv):
  # Set our Variables:

  # Check the total number of args passed - make sure we get 5 (4 + the script name that is passed by default).
  if(len(sys.argv) == 5):
    genfunc.ShowParams()
    config.ThisScript = sys.argv[0]
    config.Command =sys.argv[1]
    config.Type = sys.argv[2]
    config.Application = sys.argv[3]
    config.AppSrv = sys.argv[4]
  else:
    config.ShowUsage()
    sys.exit(1)

  return


# ###################################################################################
# Function: RemoveDirsFiles
# Description: Function for removing directories and files from the passed directory 
# Parameters: Path - The full path to remove directories and files from
#   
def RemoveDirsFiles(Path):
  DeployLogger.info("in RemoveDirsFiles: Path to remove dirs/files from = " + Path)
  
  try:
    DeployLogger.info("Deleting Dirs and Files in " + Path)

    # -------------------------------------------------------------------------
    # Recurse through the directories and sub directories and delete files:
    for root, dirs, files in os.walk(Path, topdown=False):

      # Delete all the files
      for file in files:
        try:
          fullpath = os.path.join(root, file)
          DeployLogger.info("removing file = " + fullpath)
          
          # Check if File is Read only:
          if not os.access(fullpath, os.W_OK):
            # Directory or File is read-only, make it deleteable:
            genfunc.Chmod0777(fullpath)

          # Remove File:
          os.remove(fullpath)
  
        except OSError as ose:
          DeployLogger.error("OSError = ", ose)
          DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
          config.HasError = True
          raise Exception(ose)
    
        except Exception as e:
          DeployLogger.error("Exception in removing Files in RemoveDirsFiles() =", e)
          DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
          config.HasError = True
          raise Exception(e)

    # -------------------------------------------------------------------------------------------
    # Re-curse through the directories and sub directories and Delete all the sub-directories:
    for root, dirs, files in os.walk(Path, topdown=False):  
                    
      for dir in dirs:
        dirpath = os.path.join(root, dir)
        DeployLogger.info("removing directory " + dirpath)
        try:
          # Remove Directories:
          os.rmdir(dirpath)
        except OSError as ose:
          DeployLogger.error("OSError = ", ose)
          DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
          config.HasError = True
          raise Exception(ose)
    
        except Exception as e:
          DeployLogger.error("Exception in removing subdirectories in RemoveDirsFiles()  =", e)
          DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
          config.HasError = True
          raise Exception(e)

  except Exception as e:
    DeployLogger.error("Removing Dirs and Files in " + Path + " failed.")
    DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
    config.HasError = True
    raise Exception(e)

  return




# ###################################################################################
# Function: WaitForJBoss
# Description:  Wait for JBoss/Wildfly - give it time to do the 
#               deployment or rollback/undeployment
# Parameters: None 
#
def WaitForJBoss():

  DeployLogger.info("")
  DeployLogger.info("Waiting for " + config.Application + " to be " + config.Command + "ed.")

  command = os.path.join(os.path.join(config.JbossHome, "bin"), "jboss-cli-batch.bat")
  # Correct quote setup to get double quotes where needed:
  parameters = " --connect --controller=" + config.AppSrv + " --command=:read-attribute(name=server-state)"

  # Run the JBoss CLI command:
  DeployLogger.info("running: ")
  DeployLogger.info(command + parameters)
  DeployLogger.info("")

  DeployLogger.info("Executing Sub-process to check if server is running. ")
  result = subprocess.getoutput(command + parameters)
    
  # subprocess.close
  DeployLogger.info("Sub-process result: " + result)
 
  # Check to make sure app is deployed

  if "running" in result:  
    # App is deployed.
    if os.path.exists(os.path.join(DeploymentsPath, config.Application + ".deployed"))==True:
      DeployLogger.info("The application " + config.Application + " was deployed to " + config.AppSrv)
      config.HasError = False

    # Check if the App is in a "failed" state:
    if os.path.exists(os.path.join(DeploymentsPath, config.Application + ".failed"))==True:
      DeployLogger.error("Deployment of " + config.Application + " failed!")
      config.HasError = True
      raise Exception("Deployment of " + config.Application + " failed!")

  else:
    # App is not deployed
    DeployLogger.info("The application " + config.Application + " may not be deployed yet.")

    # Check if App is still in a "deploying" state:
    if os.path.exists(os.path.join(DeploymentsPath, config.Application + ".isdeploying"))==True:
      DeployLogger.info("Application " + config.Application + " is still in isdeploying state.")
      time.sleep(4)
      WaitForJBoss()
	  
  return



# ###################################################################################
# Function: RemoveDeployedApplication
# Description:  Removes the application just deployed from the AppDeployments
#               Directory. 
# Parameter: AppToRemove - Application to Remove
# 
def RemoveDeployedApplication(AppToRemove):
  try:
    DeployLogger.info("Checking if " + AppToRemove + " exists before trying to remove.")

    if os.path.exists(AppToRemove):

      # Check if File is Read only:
      if not os.access(AppToRemove, os.W_OK):
        # Directory or File is read-only, make it deleteable:
        genfunc.Chmod0777(AppToRemove)

      DeployLogger.info(AppToRemove + " exists - removing.")
      # Remove File:
      os.remove(AppToRemove)
    else:
      DeployLogger.info(AppToRemove + " does not exists - not removing.")

  except Exception as e:
    DeployLogger.error("Undeploying/Removing File " + AppToRemove + " failed.")
    DeployLogger.error("Exception Information= ", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2])
    config.HasError = True
    raise Exception(e)
               
  return


# -----------------------------------------------------------[Execution]------------------------------------------------------------

# ************************************
# Main Script Execution
# ************************************

# Will only run if this file is called as primary file 
if __name__ == '__main__':
  
  ProcessParams(sys.argv)
  
  # Initialize Logging:
  DeployLogger = InitDeploymentLogging()

  DeployLogger.info("Parameters = " + str(sys.argv))
  #DeployLogger.debug("RSK Debug> In main - Parameters = " + config.Command + " " + config.Type + " " + config.Application + " " + config.AppSrv)
  
  DeployLogger.info("JbossHome = " + config.JbossHome)
  DeployLogger.info("Running as User = " + config.Username)


  DeployLogger.info("")
  DeployLogger.info("Starting Deployment.py script at " + genfunc.GetCurrentDateTime() + ".")
  DeployLogger.info("")
  DeployLogger.info("Running as user: " + config.Username)
  DeployLogger.info("")

  # Default paths:
  DeployPath =  os.path.join(config.JbossHome, "AppDeployments")
  AppSrvDir = os.path.join(config.JbossHome,config.AppSrv)
  DeploymentsPath = os.path.join(AppSrvDir, "deployments")
  DeploymentsBackup = os.path.join(AppSrvDir, "deploymentbackups")
  TempPath = os.path.join(AppSrvDir, "tmp")
  AppTempPath = os.path.join(TempPath, config.Application)

  try:
    # Start Main execution here:
    DeployLogger.info("Starting " + config.Command + "ment.")


    # ***** Deploy ******************************  
    if config.Command == "deploy":
      try:
        # Check if application exists in AppDeployments first:
        if os.path.exists(os.path.join(DeployPath, config.Application))==True:

          # Backup existing application first - if exists
          if os.path.exists(os.path.join(DeploymentsPath, config.Application))==True:
            DeployLogger.info("Backing up " + config.Application + " before deployment.")
            shutil.copy2(os.path.join(DeploymentsPath, config.Application), DeploymentsBackup)
        else:
          DeployLogger.error("Application " + config.Application + " does not exist in " + DeployPath + " exiting.")
          config.HasError = True
          raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), os.path.join(DeployPath, config.Application))

      except FileNotFoundError as fnfe:
        DeployLogger.error(config.ThisScript + " had an error with checking for the existance of " + os.path.join(DeploymentsPath, config.Application) + ".")
        DeployLogger.exception("FileNotFoundError - Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
        config.HasError = True
        raise Exception(fnfe)

      except IOError as ioe:
        DeployLogger.error(config.ThisScript + " had an error with copying " + os.path.join(DeploymentsPath, config.Application) + ".")
        DeployLogger.exception("IOError - Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
        config.HasError = True
        raise Exception(ioe)
        
      # If we didn't have an error from above continue on:
      if config.HasError == False:
      
        # Remove application tmp files - only if cold deploy to eliminate file locks
        if config.Type == "cold" and config.Application.lower().endswith(".war"):
          DeployLogger.info("removing all directories and files from " + TempPath + " for Applcation " + config.Application)
          RemoveDirsFiles(AppTempPath)


        # Deploy Application
        DeployLogger.info("")
        DeployLogger.info("deploying " + os.path.join(DeployPath, config.Application))
      
        # Deploy Application - verify if undeployed first, if so, deploy then set to deployable status
        if  os.path.exists(os.path.join(DeploymentsPath, config.Application + ".undeployed"))==True:
          shutil.copy2(os.path.join(DeployPath, config.Application), DeploymentsPath)
          shutil.move(os.path.join(DeploymentsPath, config.Application + ".undeployed"), os.path.join(DeploymentsPath, config.Application + ".dodeploy"))
        else:
          shutil.copy2(os.path.join(DeployPath, config.Application), DeploymentsPath)


        # If hot deploy:
        #if config.Type == "hot": 
        #  WaitForJBoss()
        #  DeployLogger.info("Removing Deployed Application from " + DeployPath)
        #  RemoveDeployedApplication(os.path.join(DeployPath, config.Application))        

        #if config.Type == "cold":
        #  WaitForJBoss()
        #  DeployLogger.info("Removing Deployed Application from " + DeployPath)
        #  RemoveDeployedApplication(os.path.join(DeployPath, config.Application))


    # ***** Poll JBoss Until Application Is Deployed or not ******************************
    # 
    elif config.Command == "polljboss":
      try:
        time.sleep(5)
        WaitForJBoss()
        DeployLogger.info("Removing Deployed Application from " + DeployPath)
        RemoveDeployedApplication(os.path.join(DeployPath, config.Application))
		  
      except Exception as e:
        DeployLogger.error("Polling JBoss for " + config.Application + " failed.")
        DeployLogger.error("Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))   
        config.HasError = True
        raise Exception(e)
			
    # ***** Undeploy ******************************
    # ToDo: Should this totally remove application or just put in an undeployed state?
    elif config.Command == "undeploy":
      # First check if %JBOSS_HOME%\%APPSRV%\deployments\%APPLICATION%.deployed exists
      try:
        DeployLogger.info("Checking if " + config.Application + " exists before undeployment.")
        if os.path.exists(os.path.join(DeploymentsPath, config.Application + ".deployed"))==True:
          DeployLogger.info(config.Application + " exists, performing undeployment.")
          
          try:
            # Check if File is Read only:
            if not os.access(os.path.join(DeploymentsPath, config.Application), os.W_OK):
              # Directory or File is read-only, make it deleteable:
              genfunc.Chmod0777(os.path.join(DeploymentsPath, config.Application))
                      
            # Remove File:
            os.remove(os.path.join(DeploymentsPath, config.Application))

            # Give deployment scanner time to see application was undeployed/removed
            time.sleep(5)
            
            # Check if .doundeploy file exists, if so remove it.
            if os.path.exists(os.path.join(DeploymentsPath, config.Application + ".doundeploy"))==True:
              # Check if File is Read only:
              if not os.access(os.path.join(DeploymentsPath, config.Application), os.W_OK):
                # Directory or File is read-only, make it deleteable:
                genfunc.Chmod0777(os.path.join(DeploymentsPath, config.Application))
            
              os.remove(os.path.join(DeploymentsPath, config.Application + ".doundeploy"))                    


            # Check if .undeployed file exists, if so remove it.
            if os.path.exists(os.path.join(DeploymentsPath, config.Application + ".undeployed"))==True:
              # Check if File is Read only:
              if not os.access(os.path.join(DeploymentsPath, config.Application), os.W_OK):
                # Directory or File is read-only, make it deleteable:
                genfunc.Chmod0777(os.path.join(DeploymentsPath, config.Application))
            
              os.remove(os.path.join(DeploymentsPath, config.Application + ".undeployed"))


          except Exception as e:
            DeployLogger.error("Undeploying/Removing File " + config.Application + " failed.")
            DeployLogger.error("Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))   
            config.HasError = True
            raise Exception(e)			

      except IOError as ioe:
        DeployLogger.error(config.ThisScript + " had an error with checking for the existance of " + os.path.join(DeploymentsPath, config.Application) + ".")
        DeployLogger.error("IOError - Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
        config.HasError = True
        raise Exception(ioe)

      # There were no errors so application undeployed successfully.
      if config.HasError==False:
        DeployLogger.info(config.Application + " undeployed.")


    # ***** Rollback ******************************
    elif config.Command == "rollback":
      DeployLogger.info("rolling back application "+ config.Application + " to previous backed up version.")
      try:   
        if os.path.exists(os.path.join(DeploymentsBackup, config.Application))==True:
          try:
            DeployLogger.info("Rolling back " + config.Application)
            shutil.copy2(os.path.join(DeploymentsBackup, config.Application), DeploymentsPath)
            
            # If hot deploy:
            if config.Type == "hot": 
              WaitForJBoss()
            
          except Exception as e:
            DeployLogger.error("Rolling back File " + config.Application + " failed.")
            DeployLogger.error("Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
            config.HasError = True
            raise Exception(e)

      except IOError as ioe:
        DeployLogger.error(config.ThisScript + " had an error with checking for the existence of " + os.path.join(DeploymentsPath, config.Application) + ".")
        DeployLogger.error("IOError - Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
        config.HasError = True
        raise Exception(ioe)

      # There were no errors so application was rolled back successfully.
      if config.HasError==False:
        DeployLogger.info(config.Application + " rolled back.")
        
    # ******************************************************
    # If we had an error anywhere above throw an exception:
    if config.HasError == True:
      raise Exception("There was an Exception in " + config.ThisScript + " please see errors generated in log file " + os.path.join(config.LogPath, config.LogFile))
 
  
  except Exception as e:
    DeployLogger.error("Execution failed.")
    DeployLogger.error("Exception Information = ".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]))
    DeployLogger.error("")
    DeployLogger.error("Deployment.py completed unsuccessfully at " + genfunc.GetCurrentDateTime() + ".")
    config.HasError = True
    sys.exit(1)

  if config.HasError==False:
    # All Went well - exiting!
    DeployLogger.info("")
    DeployLogger.info("Deployment.py completed successfully at " + genfunc.GetCurrentDateTime() + ".")
    DeployLogger.info("")
    DeployLogger.info("")
    DeployLogger.info("========================================================")
    DeployLogger.info("")
    DeployLogger.info("")
    config.HasError = False
    sys.exit(0)


# -----------------------------------------------------------[End Execution]--------------------------------------------------------
