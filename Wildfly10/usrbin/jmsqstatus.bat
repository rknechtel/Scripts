
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: jmsqstatus.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will show the status of a JMS Queues on a 
REM              server instance
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
set JMSQ=%1
set APPSRV=%2

REM Eliminate the "Press any key to continue"
NOPAUSE=true

REM Check if we got ALL parameters
if "!JMSQ!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!JMSQ!"=="" if "!APPSRV!"=="" (
  goto usage
)


REM Show the status of the JMS Queues on the server instance
echo The status of JMS Queue %JMSQ% on %APPSRV% is (Paused true/false):
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%JMSQ%/:read-attribute(name=paused,include-defaults=true)"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: jmsqstatus.bat arg1 arg2
echo arg1 = JMSQ (Example: ExpireyQueue)
echo arg2 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%