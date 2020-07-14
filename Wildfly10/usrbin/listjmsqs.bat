
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: listjmsqs.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will list all the JMS Queues on a server 
REM              instance
REM License: Copyleft
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


REM List all the JMS Queues on the server instance
echo The JMS Queues on %APPSRV% are:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/:read-children-resources(child-type=jms-queue)"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: listjmsqs.bat arg1
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%