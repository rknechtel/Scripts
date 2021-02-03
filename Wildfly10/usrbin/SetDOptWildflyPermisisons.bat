@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: SetDOptWildflyPermisisons.bat
REM Author: Richard Knechtel
REM Date: 07/08/2020
REM Description: This will call the SetDOptWildflyPermisisons.ps1
REM              PowerShell script.
REM\REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM       This MUST be run as Administrator!!!
REM
REM *********************************************************************

echo Running as user: %USERNAME%
echo.
echo PLEASE NOTE: 
echo              This MUST be run as Administrator!!!
echo.


REM set Script Path
set SCRIPTPATH=%JBOSS_HOME%\usrbin\Setup


@echo SetDOptWildflyPermisisons running - Script Path = %SCRIPTPATH%

PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetDOptWildflyPermisisons.ps1 -AppSrvInstance "%APPSRV%" -ServiceAccount "%SERVICEACCOUNT%"


REM Lets get out of here!
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%