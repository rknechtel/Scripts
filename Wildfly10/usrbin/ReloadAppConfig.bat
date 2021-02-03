
@echo off
REM ************************************************************************
REM Script Name: ReloadAppConfig.bat
REM Author: Richard Knechtel
REM Date: 10/10/2016
REM Description: Reload and App Servers configuration file 
REM              without restarting.
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

set APPSRV=%1

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage

REM Reload the App Servers configuration
echo Reloading %APPSRV% configuration:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "reload"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: ReloadAppConfig.bat
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%