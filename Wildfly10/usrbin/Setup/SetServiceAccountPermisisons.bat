
@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: SetServiceAccountPermisisons.bat
REM Author: Richard Knechtel
REM Date: 05/19/2017
REM Description: This will call the SetServiceAccountPermisisons.ps1
REM              PowerShell script.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
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
set SERVERNAME=%3

REM set Script Path
set SCRIPTPATH=%JBOSS_HOME%\usrbin\Setup

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage
if "!SERVICEACCOUNT!"=="" goto usage
if "!SERVERNAME!"=="" goto usage
if "!APPSRV!"=="" if "!SERVICEACCOUNT!"=="" if "!SERVERNAME!"=="" (
  goto usage
)

@echo SetServiceAccountPermisisons running - Script Path = %SCRIPTPATH%

PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetServiceAccountPermisisons.ps1 -AppSrvInstance "%APPSRV%" -ServiceAccount "%SERVICEACCOUNT%" -ServerName "%SERVERNAME%"


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: SetServiceAccountPermisisons.bat arg1 arg2 arg3
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
echo arg2 = Service Account (Example: DOMAIN\MyServiceAccount)
echo arg3 = Server Name (Example: mc21dwin235)
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%