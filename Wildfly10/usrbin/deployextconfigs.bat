
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: deployextconfigs.bat
REM Author: Richard Knechtel
REM Date: 08/21/2015
REM Description: This script will deploy External Configuration Files
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

REM Get parameters
set CONFIGDIR=%1
set APPSRV=%2

@echo on
echo Parameters passed: CONFIGDIR=%CONFIGDIR% , APPSRV=%APPSRV%
@echo off

REM Set default Error Level
set ERRORLEVEL=

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!CONFIGDIR!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!CONFIGDIR!"=="" if "!APPSRV!"=="" (
  goto usage
)

REM Default deploy path:
set DEPLOYPATH=%JBOSS_HOME%\AppDeployments
set BACKUPSPATH=%JBOSS_HOME%\%APPSRV%\deploymentbackups
set CONFIGPATH=%JBOSS_HOME%\%APPSRV%\ApplicationConfigurations
set CONFIGDIREXISTED="YES"

REM ****************************************************************************
REM Deploy External Configurations
REM ****************************************************************************


REM ****************************************************************************
REM Check if External Configuration Directory exists
REM ****************************************************************************
if not exist %CONFIGPATH%\%CONFIGDIR% (
  REM External Configurations don't exist - Create project specific configuration directory
  echo.  
  echo External Configuration directory %CONFIGPATH%\%CONFIGDIR% doesn't exist - Creating project specific configuration directory %CONFIGDIR%.
  mkdir %CONFIGPATH%\%CONFIGDIR%
  set CONFIGDIREXISTED="NO"
  
  echo Checking if there were Errors from creating directory
  if %ERRORLEVEL% NEQ 0 (
    set ERRORLEVEL=1
    echo.
    echo Creation of External Configuration directory %CONFIGPATH%\%CONFIGDIR% failed!
    echo.  
    goto getoutofhere
  )
)



REM ****************************************************************************
REM Backup existing External Configurations first 
REM - if directory exists - if not - create it first
REM ****************************************************************************

REM if the External Configuration Directory already existed (didn't have to be created) - do backup.
if "!CONFIGDIREXISTED!"=="YES" (
echo.
if not exist %BACKUPSPATH%\%CONFIGDIR% (
  echo Backup Configuration directory doesn't exist - creating it
  mkdir %BACKUPSPATH%\%CONFIGDIR%

  echo Checking if there were Errors from creating directory
  if %ERRORLEVEL% NEQ 0 (
    set ERRORLEVEL=1
    echo.
    echo Creation of backup Configuration directory %BACKUPSPATH%\%CONFIGDIR% failed!
    echo. 
    goto getoutofhere 
  )  
)

  echo.
  echo Backing up External Configurations in %APPSRV%\ApplicationConfigurations\%CONFIGDIR% before deployment.
  echo Running: xcopy /E /Y %CONFIGPATH%\%CONFIGDIR%\*.* %BACKUPSPATH%\%CONFIGDIR%\*
  xcopy /E /Y %CONFIGPATH%\%CONFIGDIR%\*.* %BACKUPSPATH%\%CONFIGDIR%\*

) else (
  echo.
  echo External Configuration Directory %CONFIGPATH%\%CONFIGDIR% didn't exist - no backup needs to be done.
  echo.
)







REM Copy new External Configuration Files
echo Copying new External Configuration Files
if %ERRORLEVEL% == 0 (
  echo.
  echo Copying new External Configuration files in %DEPLOYPATH%\%CONFIGDIR% to %CONFIGPATH%\%CONFIGDIR%
  xcopy /E /Y %DEPLOYPATH%\%CONFIGDIR%\*.* %CONFIGPATH%\%CONFIGDIR%\*.*
  
  echo Check if errors on Copy
  if %ERRORLEVEL% EQU 1 echo Error copying External Configuration Files. ERRORLEVEL = %ERRORLEVEL% ERRORMESSAGE=No files were found to copy.
  if %ERRORLEVEL% EQU 2 echo Error copying External Configuration Files. ERRORLEVEL = %ERRORLEVEL% ERRORMESSAGE=The user pressed CTRL+C to terminate xcopy.
  if %ERRORLEVEL% EQU 4 echo Error copying External Configuration Files. ERRORLEVEL = %ERRORLEVEL% ERRORMESSAGE=Initialization error occurred. There is not enough memory or disk space, or you entered an invalid drive name or invalid syntax on the command line.
  if %ERRORLEVEL% EQU 5 echo Error copying External Configuration Files. ERRORLEVEL = %ERRORLEVEL% ERRORMESSAGE=Disk write error occurred.
) 


if %ERRORLEVEL% EQU 0 (
  goto removeExternalConfigs
) else (
  set ERRORLEVEL=1
  echo.
  echo Deployment of %DEPLOYPATH%\%CONFIGDIR% files failed!
  echo.
  goto getoutofhere
)

REM Lets get out of here!
goto getoutofhere

:removeExternalConfigs
echo Done deploying External Configuration files for %CONFIGDIR%.
echo.
echo External Configuration files for %CONFIGDIR% deployed successfully 
echo.
echo Removing directory %CONFIGDIR% and it's contents From: %deploypath%

rmdir %deploypath%\%CONFIGDIR% /s /q

if %ERRORLEVEL% NEQ 0 (
  echo.
  echo Removal of directory %deploypath%\%CONFIGDIR% failed!
  echo.
  goto getoutofhere
)
REM Lets get out of here!
goto getoutofhere


REM ****************************************************************************
REM Usage
REM ****************************************************************************
:usage
set ERRORLEVEL=1
echo [USAGE]: deployextconfigs.bat arg1 arg2
echo arg1 = Configuration Directory (Name of Project/Jenkins Job - Example: MyApp)
echo arg2 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere


REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORLEVEL%
