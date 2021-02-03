
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: ActiveAppSessons.bat
REM Author: Richard Knechtel
REM Date: 07/21/2017
REM Description: This script will allow you to see how many active 
REM              sessions are on an Application
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM            Application (Example: MyApp.war)
REM            AppSrv Instance Name (Example: AppSrv01)
REM 
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set APPLICATION=%1
set APPSRV=%2

REM Set default Error Number
set ERRORNUMBER=0

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!APPLICATION!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!APPLICATION!"=="" if "!APPSRV!"=="" (
  goto usage
)

@echo Checking the number of active sessions on %APPLICATION% on %APPSRV%.
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/deployment=%APPLICATION%/subsystem=undertow :read-attribute(name=active-sessions)"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: ActiveAppSessons.bat arg1 arg2
echo arg1 = Application (MyApp.war)
echo arg2 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
