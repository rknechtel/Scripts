
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: listjmsmsg.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will list the messages in a JMS Queue
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


REM List Messages in JMS Queue
echo Messages in JMS Queue %JMSQ% are:
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%JMSQ%/:list-messages"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: listjmsmsg.bat arg1 arg2
echo arg1 = JMSQ (Example: ExpireyQueue)
echo arg2 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%