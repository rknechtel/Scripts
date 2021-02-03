
@echo off

setlocal EnableDelayedExpansion

REM *********************************************************************
REM Script: IsWinServiceRunning.bat
REM Author: Richard Knechtel
REM Date: 01/05/2016
REM Description: This will find the Process for the Service if it is running
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameter: Service Name
REM *********************************************************************

echo Running as user: %USERNAME%

REM Get parameters
@echo Parameters Passed = %1

set WINSRV=%1

REM Check if we got ALL parameters
if "!WINSRV!"=="" goto usage

set ERRORNUMBER=0
set ERRORMESSAGE=Success

echo Checking if Windows Service %WINSRV% is running:
FOR /F "tokens=3" %%A IN ('sc queryex %WINSRV% ^| findstr PID') DO (SET pid=%%A)
 IF "!pid!" NEQ "0" (
  echo Windows Service %WINSRV% is running.
 ) ELSE (
  echo Windows Service %WINSRV% is not running.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Windows Service %WINSRV% is not running.
 )

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: IsWinServiceRunning.bat arg1
echo arg1 = Windows Service Name (Example: Apache2.4)

goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
