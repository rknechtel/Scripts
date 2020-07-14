
@echo off
setlocal EnableDelayedExpansion
REM ***************************************************************************************
REM Script: startAppSrv.bat
REM Author: Richard Knechtel
REM Date: 12/08/2015
REM Description: This script will allow you to stop/start/restart a particular AppSrv 
REM              instance.
REM License: Copyleft
REM
REM Parameters:
REM            Command (Example: stop/start/restart)
REM            AppSrv Instance Name (Example: AppSrv01)
REM 
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM **************************************************************************************

echo Running as user: %USERNAME%

REM COMMAND = Possibles: stop, start, restart
set COMMAND=%1
set APPSRV=%2

REM Set default Error Number
set ERRORNUMBER=0

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!COMMAND!"=="" if "!APPSRV!"=="" (
  goto usage
)


if /I "%COMMAND%" == "stop"      goto cmdStop
if /I "%COMMAND%" == "start"     goto cmdStart
if /I "%COMMAND%" == "restart"   goto cmdReStart


REM Stop Application Server Instance
:cmdStop

echo Stopping %APPSRV%
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:shutdown

REM Lets get out of here!
goto getoutofhere



REM Start Application Server Instance
:cmdStart
echo Starting %APPSRV%
REM %JBOSS_HOME%\bin\standalone.bat -Djboss.server.base.dir=%JBOSS_HOME%\%APPSRV% --server-config=%APPSRV%-full.xml
call %JBOSS_HOME%\bin\standalone.bat -Djboss.server.base.dir=%JBOSS_HOME%\%APPSRV% --server-config=%APPSRV%-full.xml
REM @start /b %JBOSS_HOME%\bin\standalone.bat -Djboss.server.base.dir=%JBOSS_HOME%\%APPSRV% --server-config=%APPSRV%-full.xml
goto WaitForJBoss



REM ReStarting Application Server Instance
:cmdReStart
echo ReStarting %APPSRV%
REM %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:shutdown(restart=true)
call %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:shutdown(restart=true)
REM @start /b %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:shutdown(restart=true)
goto WaitForJBoss


:WaitForJBoss
echo Waiting for %APPLICATION% to be deployed.
timeout /t 5
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:read-attribute(name=server-state) | findstr "running"
REM call %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:read-attribute(name=server-state) | findstr "running"
REM @start /b %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=:read-attribute(name=server-state) | findstr "running"
if %ERRORLEVEL% NEQ 0 goto WaitForJBoss

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: stopstartAppSrv.bat arg1 arg2
echo arg1 = Command (Example: stop/start/restart) 
echo arg2 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%