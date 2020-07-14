@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: WinService.bat
REM Author: Richard Knechtel
REM Date: 06/14/2016
REM Description: This script will allow you to 
REM              Stop/Start/Restart/Suspend/Resume Windows Services.
REM 
REM Notes:
REM Must be run as Administrator!!
REM Example Call:
REM WinService.bat stop APPSRV01 LINUX02 local
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set SRVCMD=%1
set SERVICE=%2
set SERVER=%3
set SERVICELOC=%4

REM set Script Path
set SCRIPTPATH=C:\Scripts

REM Check if we got ALL parameters
if "!SRVCMD!"=="" goto usage
if "!SERVICE!"=="" goto usage
if "!SERVER!"=="" goto usage
if "!SERVICELOC!"=="" goto usage
if "!SRVCMD!"=="" if "!SERVICE!"=="" if "!SERVER!"=="" if "!SERVICELOC!"=="" (
  goto usage
)

PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 %SRVCMD% %SERVICE% %SERVER% %SERVICELOC%

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: WinService.bat arg1 arg2 arg3
echo arg1 = Service Command (Stop/Start/Restart/Suspend/Resume | Example: stop)
echo arg2 = Service Name (Example: AppSrv01)
echo arg3 = Server Name (Example: MyServerName)
echo arg4 = Service Locaton (Values: local/remote)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%