
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: clearmsgfromjmsq.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will clear all a specific messages in a JMS Queue
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
set JMSQ=%2
set APPSRV=%3

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!MSGID!"=="" goto usage
if "!JMSQ!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!MSGID!"=="" if "!JMSQ!"=="" if "!APPSRV!"=="" (
  goto usage
)

REM Remove/Clear Message from JMS Queue
echo Removing/clearing Message ID %MSGID% in JMS Queue %JMSQ%
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%JMSQ%:remove-message(message-id=%MSGID%)"

echo Message ID %MSGID% in JMS Queue %JMSQ% cleared.

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: clearmsgfromjmsq.bat arg1 arg2 arg3
echo arg1 = JMS MSG ID (Example: ID:128966dd-b3e7-11e5-b7de-23d36474d8c7)
echo arg2 = JMSQ (Example: ExpireyQueue)
echo arg3 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%