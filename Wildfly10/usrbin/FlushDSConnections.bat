
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script Name: FlushDSConnections.bat
REM Description: Flush all connections in a Non-XA Datasource.
REM Author: Richard Knechtel
REM Date: 04/12/2016
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters: AppSrvxx
REM             Datasource
REM
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set APPSRV=%1
set DATASOURCE=%2

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

if "!APPSRV!"=="" goto usage
if "!DATASOURCE!"=="" goto usage
if "!APPSRV!"=="" if "!DATASOURCE!"=="" (
  goto usage
)

REM This lists  the data-source operations:
REM %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "data-source --help --commands"

REM Test the Datasource connection
echo Flushing connections in datasource %DATASOURCE%:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c " data-source flush-all-connection-in-pool --name=%DATASOURCE%"


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: FlushDSConnections.bat arg1 arg2
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
echo arg2 = Non-XA Datasource (MyAppDS)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%