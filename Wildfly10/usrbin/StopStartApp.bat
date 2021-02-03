
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: StopStartApp.bat
REM Author: Richard Knechtel
REM Date: 12/08/2015
REM Description: This script will allow you to 
REM              stop/start (undeploy/deploy)
REM              and application.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM            Command (Example: stop/start)
REM            Application (Example: MyApp.war)
REM            AppSrv Instance Name (Example: AppSrv01)
REM 
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set COMMAND=%1
set APPLICATION=%2
set APPSRV=%3

REM Set default Error Number
set ERRORNUMBER=0

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage
if "!APPLICATION!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!COMMAND!"=="" if "!APPLICATION!"=="" if "!APPSRV!"=="" (
  goto usage
)

if /I "%COMMAND%" == "start" goto cmdStart
if /I "%COMMAND%" == "stop" goto cmdStop

REM Stop/Undeploy app:
:cmdStop
REM First check if %JBOSS_HOME%\%APPSRV%\deployments\%APPLICATION%.deployed exists
@echo Stopping %APPLICATION% on %APPSRV%.
REM %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "ls deployment" | findstr %APPLICATION%
for /f "tokens=1" %%i in ('"%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "ls deployment"" ^| findstr %APPLICATION%') do set "APP=%%i"

if "!APP!"=="" (
  @echo on
  echo Application %APPLICATION% is not deployed, unable to stop it - exiting.
  set ERRORNUMBER=1
  @echo off
) else (
  %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="undeploy %APPLICATION% --keep-content"
)
REM Lets get out of here!
goto getoutofhere

REM Start/Deploy app:
:cmdStart

REM Verify if Appication is already delpoyed.
@echo Starting %APPLICATION% on %APPSRV%.
REM %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="deploy --name=%APPLICATION% --force"
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="deploy --name=%APPLICATION%"

REM with using the undeploy command with --keep-content the .war file will always be there just not enabled.
REm Commenting the below out.
REM for /f "tokens=1" %%i in ('"%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "ls deployment"" ^| findstr %APPLICATION%') do set "APP=%%i"
REM @echo APP = %APP%
REM if "!APP!"=="" (
REM   %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="deploy --name=%APPLICATION% --force"
REM ) else (
REM   @echo on
REM   echo Application %APPLICATION% is not stopped, unable to start it - exiting.
REM   set ERRORNUMBER=1
REM   @echo off
REM )

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: StopStartApp.bat arg1 arg2 arg3
echo arg1 = Command (start / stop)
echo arg2 = Application (MyApp.war)
echo arg3 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
