
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: deployment.bat
REM Author: Richard Knechtel
REM Date: 04/05/2015
REM Description: This script will allow you to do a Hot or Cold
REM              Deploy/Undeploy an application.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.
echo Note: This script ONLY supports applications WITHOUT version numbers in the name.
echo.

REM Get parameters
set COMMAND=%1
set TYPE=%2
set APPLICATION=%3
set APPSRV=%4

@echo on
echo Parameters passed: TYPE=%TYPE% , COMMAND=%COMMAND% , APPLICATION=%APPLICATION% , APPSRV=%APPSRV%
@echo off

REM Set default Error Level
set ERRORLEVEL=0

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage
if "!TYPE!"=="" goto usage
if "!APPLICATION!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!COMMAND!"=="" if "!TYPE!"=="" if "!APPLICATION!"=="" if "!APPSRV!"=="" (
  goto usage
)

REM Default deploy path:
set deploypath=%JBOSS_HOME%\AppDeployments
set deploymentspath=%JBOSS_HOME%\%APPSRV%\deployments
set temppath=%JBOSS_HOME%\%APPSRV%\tmp


if /I "%COMMAND%" == "deploy"     goto cmdDeploy
if /I "%COMMAND%" == "undeploy"   goto cmdUndeploy


REM ****************************************************************************
REM Deploy Application
REM ****************************************************************************
:cmdDeploy
REM Backup existing application first - if exists
echo.
if exist %deploymentspath%\%APPLICATION% (
  echo Backing up %APPLICATION% before deployment.
  copy /Y %deploymentspath%\%APPLICATION% %JBOSS_HOME%\%APPSRV%\deploymentbackups\*.* >NUL
) else (
  REM Application not deployed - copy to deployments folder
  echo %APPLICATION% not deployed - copying to deployments folder.
  copy /Y %deploypath%\%APPLICATION% %JBOSS_HOME%\%APPSRV%\deployments\*.* >NUL
)

REM Remove tmp files
echo removing all directories and files from %temppath% for Applcation %APPLICATION%
del /f /s /q %temppath%\%APPLICATION%\*


REM Deploy Application
echo.
echo deploying %deploymentspath%\%APPLICATION%
REM Deploy Application - verify if undeployed first, if so, deploy then set to deployable status
if exist %deploymentspath%\%APPLICATION%.undeployed (
  copy /Y %deploypath%\%APPLICATION% %deploymentspath%
  move %deploymentspath%\%APPLICATION%.undeployed %JBOSS_HOME%\%APPSRV%\deployments\%APPLICATION%.dodeploy
  
) else (
  copy /Y %deploypath%\%APPLICATION% %deploymentspath%
)

if /I "%TYPE%" == "hot" goto waitForJBoss

REM If a "cold" deploy - just rmeove app from deploypath:
if /I "%TYPE%" == "cold" (
  goto removeDeployedApp
  goto getoutofhere
)


REM ****************************************************************************
REM Undeploy Application
REM ****************************************************************************
:cmdUndeploy
REM First check if %JBOSS_HOME%\%APPSRV%\deployments\%APPLICATION%.deployed exists
if exist %deploymentspath%\%APPLICATION%.deployed (
  echo.
  echo UnDeploying %deploymentspath%\%APPLICATION%
  move %deploymentspath%\%APPLICATION%.deployed %deploymentspath%\%APPLICATION%.doundeploy
) else (
  echo.
  echo Application %APPLICATION% is not deployed, unable to undeploy it - exiting.
)

if /I "%TYPE%" == "hot" goto waitForJBoss
if /I "%TYPE%" == "cold"  goto getoutofhere



REM ****************************************************************************
REM Wait for JBoss/Wildfly - give it time to do the deployment/undeployment
REM ****************************************************************************
:waitForJBoss
echo.
echo Waiting for %APPLICATION% to be %COMMAND%ed.
timeout /t 5
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="deployment-info --name=%APPLICATION%" | findstr /c:"OK"

if %ERRORLEVEL% NEQ 0 (
  goto waitForJBoss
) else (
  echo.
  echo --------------------------------------------
  REM Check to make sure app is deployed
  echo.
  call deployinfo.bat %APPSRV%
  echo.
  echo --------------------------------------------
  echo.

   if /I "%COMMAND%" == "deploy" (
     REM If deploy was successful (no erros) - remove deployment file
     echo Done deploying %APPLICATION% - check above to see if application is Enabled and status is "OK".
     goto removeDeployedApp
   )
   if /I "%COMMAND%" == "undeploy" (
     if exist %deploymentspath%\%APPLICATION%.doundeploy (
	   del /Q %deploymentspath%\%APPLICATION%.doundeploy
	 )     
     echo.
     echo Done undeploying %APPLICATION% - check above to verify application is not listed.
   )
)

REM Lets get out of here!
goto getoutofhere

:removeDeployedApp
echo Done deploying %APPLICATION%.
echo.
echo %APPLICATION% deployed successfully 
echo.
echo Removing: %APPLICATION% From: %deploypath%"
del /Q %deploypath%\%APPLICATION%
EXIT /B

REM ****************************************************************************
REM Usage
REM ****************************************************************************
:usage
set ERRORLEVEL=1
echo [USAGE]: Deployment.bat arg1 arg2 arg3 arg4
echo arg1 = Command (deploy / undeploy)
echo arg2 = Type (hot / cold)
echo arg3 = Application (Example: MyApp.war)
echo arg4 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORLEVEL%
