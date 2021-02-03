
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: ArchiveLogs.bat
REM Author: Richard Knechtel
REM Date: 01/27/2016
REM Description: This script will allow you to
REM              Archive Wildfly Log files 
REM             and optionally purge old archives (by number of days)
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
REM ************************************************************************

@echo.
@echo ******************************************
@echo This script MUST be run as Administrator.
@echo ******************************************
@echo.
@echo Running as user: %USERNAME%
@echo.

REM Set default Error Level
set ERRORLEVEL=0
set ERRORNUMBER=0
set ERRORMESSAGE=Success

CALL :check_Permissions

if %ERRORNUMBER% NEQ 0 (
  set ERRORNUMBER=1
  set ERRORMESSAGE=You need Administrative privileges to run this script!
  REM Lets get out of here!
  goto getoutofhere
) Else (
 set ERRORNUMBER=0
 set ERRORMESSAGE=Success
)

REM Get parameters
@echo Parameters Passed = %1 %2 %3
@echo.
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
REM set Script Path
set SCRIPTPATH=D:\Scripts

REM set SERVICE variable - Convert AppSrv instance to upper case for Windows Service:
REM To convert the AppSrv instance to upper case we are going to use a hack and abuse the tree commands error message - just 'cause we can!
set upper=
set str=%APPSRV%
for /f "skip=2 delims=" %%I in ('tree "\%str%"') do if not defined upper set "upper=%%~I"
set "upper=%upper:~3%"
set SERVICE=WF10%upper%
echo service=%SERVICE%



@echo 

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
REM @echo calling %JBOSS_HOME%\usrbin\ArchiveLogs.ps1 %LOGDIR% %ARCHIVELOGDIR% %ZIPFILE%
REM PowerShell -ExecutionPolicy Bypass -File %JBOSS_HOME%\usrbin\ArchiveLogs.ps1 %APPSRV% %ZIPFILE%

REM Jython Version:
REM @echo calling %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py %LOGDIR% %ZIPFILE%
REM @echo JYTHON_HOME = %JYTHON_HOME%
REM call %JYTHON_HOME%\bin\jython %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py %APPSRV% %ZIPFILE%

REM Python Version:
@echo calling %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py %LOGDIR% %ZIPFILE%
@echo PYTHON_HOME = %PYTHON_HOME%
call %PYTHON_HOME%\python %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py %APPSRV% %ZIPFILE%

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Archive Of Logs Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Archive Of Logs Failed.
) else (
  @echo Archive Of Logs Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Archive Of Logs Succeeded.
)


REM 5) Start AppSrv Instance Windows service.
if /I "!RESTARTINSTANCE!" EQU "yes" (
  @echo Starting %SERVICE% Windows Service
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "start" %SERVICE% %SERVER% "local"
)

REM 6) Check to make sure Apps are in deployed state.
REM WORK ON!

REM OPTIONAL:
REM 7) Delete Archived log files (more than 30 days old).
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

:check_Permissions
    echo Administrative permissions required. Detecting permissions...
    echo.
	
	REM  Calling verify with no args just checks the verify flag,
    REM   we use this for its side effect of setting errorlevel to zero
    verify >nul

    REM  Attempt to read a particular system directory - the DIR
    REM   command will fail with a nonzero errorlevel if the directory is
    REM   unreadable by the current process.  The DACL on the
    REM   c:\windows\system32\config\systemprofile directory, by default,
    REM   only permits SYSTEM and Administrators.
    dir %windir%\system32\config\systemprofile >nul 2>nul

    REM  Use IF ERRORLEVEL or %errorlevel% to check the result
    if not errorlevel 1 (
        echo Success: Administrative permissions confirmed.
        set ERRORNUMBER=0
        set ERRORMESSAGE=Success: Administrative permissions confirmed
    )
    if errorlevel 1 (
       echo ######## ########  ########   #######  ########  
       echo ##       ##     ## ##     ## ##     ## ##     ## 
       echo ##       ##     ## ##     ## ##     ## ##     ## 
       echo ######   ########  ########  ##     ## ########  
       echo ##       ##   ##   ##   ##   ##     ## ##   ##   
       echo ##       ##    ##  ##    ##  ##     ## ##    ##  
       echo ######## ##     ## ##     ##  #######  ##     ## 
       echo.
       echo.
       echo ####### ERROR: ADMINISTRATOR PRIVILEGES REQUIRED #########
       echo This script must be run as administrator to work properly!  
       echo If you're seeing this after clicking on a start menu icon, 
       echo then right click on the shortcut and select
       echo "Run As Administrator".
       echo ##########################################################
       echo.
       set ERRORNUMBER=1
       set ERRORMESSAGE=You need Administrative privileges to run this script! 
    )
    EXIT /B %ERRORNUMBER%



:usage
set ERRORNUMBER=1
echo [USAGE]: ArchiveLogs.bat arg1 arg2 arg3
echo arg1 = AppSrv Instance (Example: AppSrv01)
echo arg2 = Should AppSrv Instance be restarted (Example: no)
echo arg3 (Optional) = Days Older than to Purge (Example: 30)
echo                   Note: This will purge any logs older than 30 days.

goto getoutofhere

:getoutofhere
@echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORNUMBER% %ERRORMESSAGE%

REM END
