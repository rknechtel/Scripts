
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: pauseresumejmsq.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will pause or resume a JMS Queue
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
set COMMAND=%1
set JMSQ=%2
set APPSRV=%3

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage
if "!JMSQ!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!COMMAND!"=="" if "!JMSQ!"=="" if "!APPSRV!"=="" (
  goto usage
)

if /I "%COMMAND%" == "pause"     goto cmdPause
if /I "%COMMAND%" == "resume"    goto cmdResume


REM Pause the JMS Queue
:cmdPause
echo Pausing JMS Queue %JMSQ%
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%JMSQ%/:pause"
echo JMS Queue %JMSQ% Paused.

REM Lets get out of here!
goto getoutofhere


REM Resume the JMS Queue
:cmdResume
echo "Resuming JMS Queue %JMSQ%"
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/subsystem=messaging/hornetq-server=default/jms-queue=%JMSQ%/:resume"
echo JMS Queue %JMSQ% Resumed.

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: pauseresumejmsq.bat arg1 arg2 arg3"
echo arg1 = Command (pause / resume)
echo arg2 = JMS Queue Name (Example: ExpiryQueue)
echo arg3 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%