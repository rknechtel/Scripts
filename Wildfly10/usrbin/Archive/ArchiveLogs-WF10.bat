
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: ArchiveLogs.bat
REM Author: Richard Knechtel
REM Date: 01/27/2016
REM Description: This script will allow you to
REM              Archive Wildfly Log files 
REM              and optionally purge old archives (by number of days)
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM   Must be run as Administrator!!
REM   Because it needs admin authority for stopping/starting Windows services.
REM   Example Call:
REM   ArchiveLogs.bat AppSrv01
REM   Or to Purge:
REM   ArchiveLogs.bat AppSRv01 30
REM
REM   Also need a ZIP7_HOME environment variable:
REM   Local Systems:
REM   setX ZIP7_HOME "C:\Program Files\7-Zip" /m
REM   On Wildfly Servers:
REM   setX ZIP7_HOME "D:\Apps\7-Zip" /m
REM 
REM Remove An Environment Variable:
REM setX ZIP7_HOME "" -m
REM
REM ************************************************************************

echo.
echo ******************************************
echo This script MUST be run as Administrator.
echo ******************************************
echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
set APPSRV=%1
set RESTARTINSTANCE=%2
set PURGE=%3

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage
if "!RESTARTINSTANCE!"=="" goto usage
if "!APPSRV!"=="" if "!RESTARTINSTANCE!"=="" (
  goto usage
)

REM Get servers hostname for SERVER:
for /F "usebackq" %%i in (`hostname`) do set SERVER=%%~i
echo server=%SERVER%

REM Setup needed variables:
set LOGDIR=%JBOSS_HOME%\%APPSRV%\log
set ARCHIVELOGDIR=%LOGDIR%\Archive
set SERVICELOC=local

REM set SERVICE variable - Convert AppSrv instance to upper case for Windows Service:
REM To convert the AppSrv instance to upper case we are going to use a hack and abuse the tree commands error message - just 'cause we can!
set upper=
set str=%wilAPPSRV%
for /f "skip=2 delims=" %%I in ('tree "\%str%"') do if not defined upper set "upper=%%~I"
set "upper=%upper:~3%"
set SERVICE=WF10%upper%
echo service=%SERVICE%

REM set Script Path
set SCRIPTPATH=C:\Scripts

@echo *********************************************************************************************************
@echo Starting Archive Process
@echo *********************************************************************************************************

REM 1) Stop AppSrv instance
if /I "!RESTARTINSTANCE!" EQU "yes" (
  @echo Stopping %SERVICE% Windows Service
  @echo PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "stop" %SERVICE% %SERVER% "local"
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "stop" %SERVICE% %SERVER% "local"
)


REM Get the Current date as MM-dd-yyyy format and set Zip File Name
for /f %%a in ('powershell -Command "Get-Date -format MM-dd-yyyy"') do set mmddyyyy=%%a

set ZIPFILE=%mmddyyyy%-%APPSRV%-Logs.zip
@echo Zip File Name = %ZIPFILE%

REM Steps 2) Zip up log files.
@echo calling %JBOSS_HOME%\usrbin\ArchiveLogs.ps1 %LOGDIR% %ARCHIVELOGDIR% %ZIPFILE%
PowerShell -ExecutionPolicy Bypass -File %JBOSS_HOME%\usrbin\ArchiveLogs.ps1 %APPSRV% %ZIPFILE%

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
@echo Archive Of Logs Succeeded.
) else (
  @echo Archive Of Logs Failed.
)


REM 5) Start AppSrv Instance Windows service.
if /I "!RESTARTINSTANCE!" EQU "yes" (
  @echo Starting %SERVICE% Windows Service
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "start" %SERVICE% %SERVER% "local"
)

REM OPTIONAL:
REM 6) Delete Archived log files (more than 30 days old).
if NOT "!PURGE!"=="" (

  echo %PURGE%| findstr /r "^[1-9][0-9]*$">nul
  if %errorlevel% equ 0 (
    REM PURGE contains a valid number - Do purge:
	@echo Purging archived log files for %APPSRV% that are older than %PURGE% days	
	PowerShell -Command "Get-ChildItem '%ARCHIVELOGDIR%' | Where {$_.lastwritetime -lt (Get-Date).AddDays(-%PURGE%)} | Remove-Item -Force -ErrorAction SilentlyContinue"
  )
  
)

@echo *********************************************************************************************************
@echo Finished Archive Process
@echo *********************************************************************************************************

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: ArchiveLogs.bat arg1 arg2 arg3
echo arg1 = AppSrv Instance (Example: AppSrv01)
echo arg2 = Should AppSrv Instance be restarted (Example: no)
echo arg3 (Optional) = Days Older than to Purge (Example: 30)
echo                   Note: This will purge any logs older than 30 days.

goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER% %ERRORMESSAGE%

REM END