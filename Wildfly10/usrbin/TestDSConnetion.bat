
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script Name: TestDSConnetion.bat
REM Description: Test a Non-XA Datasource connetion.
REM Author: Richard Knechtel
REM Date: 04/11/2016
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

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage
if "!DATASOURCE!"=="" goto usage
if "!APPSRV!"=="" if "!DATASOURCE!"=="" (
  goto usage
)

REM Test the Datasource connection
REM This lists  the data-source operations:
REM %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "data-source --help --commands"
echo Testing datasource %DATASOURCE% connection:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% -c "/subsystem=datasources/data-source=%DATASOURCE%:test-connection-in-pool"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: TestDSConnetion.bat arg1 arg2
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
echo arg2 = Non-XA Datasource (MyAppDS)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%