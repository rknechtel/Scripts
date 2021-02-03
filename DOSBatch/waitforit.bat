@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: waitforit.bat
REM Author: Richard Knechtel
REM Date: 05/18/2017
REM Description: This will wait for some task to complete
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM *********************************************************************

echo Running as user: %USERNAME%
echo.

set TIMETOWAIT=%1

REM Check if we got the parameter
if "!TIMETOWAIT!"=="" goto usage


REM Wait with no output
echo Waiting %TIMETOWAIT% seconds for some task to fully complete
REM timeout /t %TIMETOWAIT% /nobreak > NUL
start timeout /t %TIMETOWAIT% /nobreak > NUL

goto getoutofhere
 

:usage
set ERRORNUMBER=1
echo [USAGE]: waitforit.bat arg1 arg2
echo arg1 = Time (in seconds) to Wait (Example: 300)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%