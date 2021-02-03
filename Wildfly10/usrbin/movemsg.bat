
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: movemsg.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will move a message in one JMS Queue
REM              to another JMS Queue
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
set MSGID=%1
set SRCJMSQ=%2
set DESTJMSQ=%3
set APPSRV=%4

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!MSGID!"=="" goto usage
if "!SRCJMSQ!"=="" goto usage
if "!DESTJMSQ!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!MSGID!"==" if "!SRCJMSQ!"=="" if "!DESTJMSQ!"=="" if "!APPSRV!"=="" (
  goto usage
)

REM Move a JMS Message from the Source JMS Queue to the Destination JMS Queue
echo Moving Message %MSGID% in JMS Queue %SRCJMSQ% to JMS Queue %DESTJMSQ%:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%SRCJMSQ%/:move-message(other-queue-name=%DESTJMSQ%,message-id=%MSGID%)"

echo Message %MSGID% in JMS Queue %SRCJMSQ% moved to JMS Queue %DESTJMSQ%.

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: movemsg.bat arg1 arg2 arg3 arg4
echo arg1 = JMS Message ID (Example: ID:128966dd-b3e7-11e5-b7de-23d36474d8c7)
echo arg2 = Source JMS Queue Name (Example: exceptionQueue)
echo arg3 = Destination JMS Queue Name (Example: myappQueue)
echo arg4 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%