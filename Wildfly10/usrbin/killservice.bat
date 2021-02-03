
@echo off
REM *********************************************************************
REM Script: killservice.bat
REM Author: Richard Knechtel
REM Description: This will find the Process for the AppSrv and kill it.
REM Date: 01/05/2016
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM *********************************************************************

echo Running as user: %USERNAME%

set APPSRV=%1
echo Killing AppSrv%APPSRV%
FOR /F "tokens=3" %%A IN ('sc queryex %APPSRV% ^| findstr PID') DO (SET pid=%%A)
 IF "!pid!" NEQ "0" (
  taskkill /f /t /pid !pid!
 )
