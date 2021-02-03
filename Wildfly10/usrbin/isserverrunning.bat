
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: isserverrunning.bat
REM Author: Richard Knechtel
REM Date: 04/20/2015
REM Description: This script will tell you if a server instance is running.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set APPSRV=%1

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage

%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:read-attribute(name=server-state) | findstr running

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: Deployment.bat arg1
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%