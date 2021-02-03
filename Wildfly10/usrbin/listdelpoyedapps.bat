
@echo off
REM ************************************************************************
REM Script Name: listdelpoyedapps.bat
REM Description: List deployed applications the server instance
REM Author: Richard Knechtel
REM Date: 03/04/2016
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters: AppSrvxx
REM
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set APPSRV=%1

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM List the Deployed Applications
echo The Applications deployed on %APPSRV% are:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "ls deployment"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: listdelpoyedapps.bat arg1
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%