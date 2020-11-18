REM ************************************************************************
REM Script Name: ServerRestart.bat
REM Author: Richard Knechtel
REM Date: 09/25/2015
REM Description: Restart a server
REM
REM
REM Note: This script MUST be run as ADMINISTRATOR!
REM
REM ************************************************************************

echo Running as user: %USERNAME%
 

REM Get parameters
set RESTARTYPE=%1
set SERVERNAME=%2
set RESTARTCOMMENT=%3

REM Set default Error Number
set ERRORNUMBER=0
 

REM Check if we got ALL parameters
if "!RESTARTYPE!"=="" goto usage


if "!SERVERNAME!"=="" (
  echo SERVERNAME is empty running a local Server Restart
) else (
  if "!RESTARTCOMMENT!"=="" goto usage
  echo SERVERNAME is not empty running a remote Server Restart
)

 

@echo Processing the Restart Type given: %RESTARTYPE%
REM ******************************************************
REM Process the Restart Type:
REM ******************************************************
if /I "%RESTARTYPE%" == "local"     goto local
if /I "%RESTARTYPE%" == "remote"      goto remote
 

REM Local Server Restart
:local
REM Call PowerShell to restart the server
PowerShell -ExecutionPolicy Bypass -Command shutdown /f /r


REM Lets get out of here!
goto getoutofhere
 

REM Remote Server Restart
:remote
REM Restart Server Remotely
shutdown /r /f /m \\%SERVERNAME% /c "%RESTARTCOMMENT%"


REM Lets get out of here!
goto getoutofhere

 

:usage
set ERRORNUMBER=1
echo [USAGE]: ServerRestart.bat arg1 arg2 arg3
echo arg1 = Restart Type (local / remote)
echo arg2 = (Optional) Server Name (If "Restart Type" is "remote")
echo arg3 = (Optional) Restart Comment (If "Restart Type" is "remote")
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%