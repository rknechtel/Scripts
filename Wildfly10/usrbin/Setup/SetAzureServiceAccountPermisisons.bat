@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: SetAzureServiceAccountPermisisons.bat
REM Author: Richard Knechtel
REM Date: 09/10/2017
REM Description: This will call the SetAzureServiceAccountPermisisons.ps1
REM              PowerShell script.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM       This MUST be run as Administrator!!!
REM       When passing in a service Account - pass it in with double Quotes
REM       Example: "DOMAIN\MyServiceAccount" OR "ServerName\MyServiceAccount"
REM *********************************************************************

echo Running as user: %USERNAME%
echo.
echo PLEASE NOTE: 
echo              This MUST be run as Administrator!!!
echo              You must enclose a service Account in double Quotes
echo              Example: "DOMAIN\MyServiceAccount" OR "ServerName\MyServiceAccount"
echo.

set APPSRV=%1
set SERVICEACCOUNT=%2

REM set Script Path
set SCRIPTPATH=%JBOSS_HOME%\usrbin\Setup

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage
if "!SERVICEACCOUNT!"=="" goto usage
if "!APPSRV!"=="" if "!SERVICEACCOUNT!"=="" (
  goto usage
)

@echo SetAzureServiceAccountPermisisons running - Script Path = %SCRIPTPATH%

PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetAzureServiceAccountPermisisons.ps1 -AppSrvInstance "%APPSRV%" -ServiceAccount "%SERVICEACCOUNT%"


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: SetAzureServiceAccountPermisisons.bat.bat arg1 arg2
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
echo arg2 = Service Account (Example: "DOMAIN\MyServiceAccount" OR "ServerName\MyServiceAccount")
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%