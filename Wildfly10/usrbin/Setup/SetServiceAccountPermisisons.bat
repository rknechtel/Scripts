@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: SetServiceAccountPermisisons.bat
REM Author: Richard Knechtel
REM Date: 05/19/2017
REM Description: This will call the SetServiceAccountPermisisons.ps1
REM              PowerShell script.
REM
REM Notes:
REM       This MUST be run as Administrator!!!
REM       When passing in a service Account - pass it in with double Quotes
REM       Example: "DOMAIN\MyServiceAccount"
REM *********************************************************************

echo Running as user: %USERNAME%
echo.
echo PLEASE NOTE: 
echo              This MUST be run as Administrator!!!
echo              You must enclose a service Account in double Quotes
echo              Example: "DOMAIN\MyServiceAccount"
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

PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetServiceAccountPermisisons.ps1 -AppSrvInstance "%APPSRV%" -ServiceAccount "%SERVICEACCOUNT%"


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: SetServiceAccountPermisisons.bat arg1 arg2
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
echo arg2 = Service Account (Example: DOMAIN\MyServiceAccount)
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%