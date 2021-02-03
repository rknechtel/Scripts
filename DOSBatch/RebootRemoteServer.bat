
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: RebootRemoteServer.bat
REM Author: Richard Knechtel
REM Date: 02/03/2021
REM Description: This script will allow you to Reboot a Remote Server
REM
REM LICENSE:
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM            SERVERNAME (Example: mc21dwin235)
REM            COMMENT (Excample: Services Hung)
REM 
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set SERVERNAME=%1
set COMMENT=%2

REM Set default Error Number
set ERRORNUMBER=0
REM Check if we got ALL parameters
if "!SERVERNAME!"=="" goto usage
if "!COMMENT!"=="" goto usage
if "!SERVERNAME!"=="" if "!PASSWORD!"=="" (
  goto usage
)

@echo Restarting Server: %SERVERNAME% because of %COMMENT%
SHUTDOWN /r /f /t 0 /m \\%SERVERNAME% /c "%COMMENT%"


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: RebootRemoteServer.bat arg1 arg2
echo arg1 = Server Name (Example: mc21dwin235)
echo arg2 = Comment (Example: "Services Hung")
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%