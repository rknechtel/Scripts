@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: UpdateWindowsService.bat
REM Author: Richard Knechtel
REM Date: 04/03/2019
REM Description: This script will Update the Wildfly AppSrv Instance
REM               Account that runs it.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM   Must be run as Administrator!!
REM 
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
@echo Parameters Passed = %1 %2 %3
set WINSERVICE=%1
set WINSERVICEACCOUNT=%2
set WINSERVICEACCOUNTPW=%3

REM Check if we got ALL parameters
if "!WINSERVICE!"=="" if "!WINSERVICEACCOUNT!"=="" if "!WINSERVICEACCOUNTPW!"=="" (
   goto usage
)


REM Set default Error Level
set ERRORLEVEL=0
set ERRORMESSAGE=Success

REM ****************************************************************************
REM Install Windows Service
REM ****************************************************************************


echo.
echo Updating AppSrv Windows Service %WINSERVICE% with login credentials.
echo.

D:\opt\NSSM\nssm64.exe set %WINSERVICE% ObjectName %WINSERVICEACCOUNT% "%WINSERVICEACCOUNTPW%"
  
REM Lets get out of here!
goto getoutofhere  



REM ****************************************************************************
REM Usage
REM ****************************************************************************
:usage
set ERRORLEVEL=1
echo [USAGE]: UpdateWindowsService.bat arg1 arg2 arg3
echo arg1 = Windows Service Name (Example: WF10APPSRV09)
echo arg2 = Service Account Name (Example: MyServerName\MyServiceAccount)
echo arg3 = Service Account Password (Example: MyServiceAccountPW)
goto getoutofhere


REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
@echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORLEVEL% %ERRORMESSAGE%
