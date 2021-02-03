
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: moveallmsgs.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will move all messages in one JMS Queue
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
set SRCJMSQ=%1
set DESTJMSQ=%2
set APPSRV=%3

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!SRCJMSQ!"=="" goto usage
if "!DESTJMSQ!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!SRCJMSQ!"=="" if "!DESTJMSQ!"=="" if "!APPSRV!"=="" (
  goto usage
)


REM Move all Messages from the Source JMS Queue to the Destination JMS Queue
echo Moving all Messages in JMS Queue %SRCJMSQ% to JMS Queue %DESTJMSQ%:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%SRCJMSQ%/:move-messages(other-queue-name=%DESTJMSQ%)"

echo All Messages in JMS Queue %SRCJMSQ% to JMS Queue %DESTJMSQ%.

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: moveallmsgs.bat arg1 arg2 arg3
echo arg1 = Source JMS Queue Name (Example: exceptionQueue)
echo arg2 = Destination JMS Queue Name (Example: myappQueue)
echo arg3 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%