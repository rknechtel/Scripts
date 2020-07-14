
@echo off

setlocal EnableDelayedExpansion

REM *********************************************************************
REM Script: VerifyWindowsUpdates.bat
REM Author: Richard Knechtel
REM Date: 01/05/2016
REM Description: This will verify if windows updates were applied for a 
REM              specific server for a date 
REM              in M/DD/YYYY and MM/DD/YYYY format (Respectively)
REM Parameters: Server Name, Installed on Date
REM 
REM *********************************************************************

echo Running as user: %USERNAME%

REM Get parameters
@echo Parameters Passed = %1 %2
set SERVER=%1
set UPDDATE=%2

REM Check if we got BOTH parameters
if "!SERVER!"=="" goto usage
if "!UPDDATE!"=="" goto usage
if "!SERVER!"=="" if "!UPDDATE!"=="" (
  goto usage
)

echo Checking if Windows Updates on Server %SERVER% for %UPDDATE% were applied:
FOR /F "tokens=8" %%A IN ('wmic /node:%SERVER% qfe list ^| findstr %UPDDATE%') DO (SET dte=%%A)
 IF "!dte!" NEQ "%UPDDATE%" (
  echo Windows Updates on Server %SERVER% for %UPDDATE% were not applied.
 ) ELSE (
  echo Windows Updates on Server %SERVER% for %UPDDATE% were applied.
 )

 REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: VerifyWindowsUpdates.bat arg1 arg2
echo arg1 = (Server) (Example: MyServer)
echo arg2 = (Update Date) (Date updates installed on: Example 8/15/2018 or 10/18/2018)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
