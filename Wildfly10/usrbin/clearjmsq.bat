
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: clearjmsq.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will clear all the messages in a JMS Queue
REM License: Copyleft
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
set NOPAUSE=true

REM Check if we got ALL parameters
if "!JMSQ!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!JMSQ!"=="" if "!APPSRV!"=="" (
  goto usage
)


REM Remove/Clear all Messages from JMS Queue
echo Removing/clearing all Messages in JMS Queue %JMSQ%
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%JMSQ%:remove-messages(filter="")"

echo All Messages in JMS Queue %JMSQ% cleared.

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: clearjmsq.bat arg1 arg2
echo arg1 = JMSQ (ExpireyQueue)
echo arg2 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%