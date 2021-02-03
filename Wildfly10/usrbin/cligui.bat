
@echo off
REM ************************************************************************
REM Script Name: cligui.bat
REM Author: Richard Knechtel
REM Date: 07/19/2016
REM Description: Run the JBoss/Wildfly CLI GUI
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM            AppSrv Instance Name (Example: AppSrv01)
REM
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set APPSRV=%1

REM Set default Error Number
set ERRORNUMBER=0

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

%JBOSS_HOME%\bin\jboss-cli.bat --gui --connect --controller=%APPSRV%

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: cligui.bat arg1
echo arg1 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
