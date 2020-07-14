@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: ArchiveApacheLogs.bat
REM Author: Richard Knechtel
REM Date: 10/31/2018
REM Description: This script will allow you to
REM              Archive Apache Log files 
REm              and optionally purge old archives (by number of days)
REM
REM Notes:
REM   Must be run as Administrator!!
REM   Because it needs admin authority for stopping/starting Windows services.
REM
REM   Example Call:
REM   ArchiveApacheLogs.bat yes
REM   Or to Purge:
REM   ArchiveApacheLogs.bat yes 30
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
set RESTARTAPACHE=%1
set PURGE=%2

REM Check if we got ALL parameters
if "!RESTARTAPACHE!"=="" goto usage

REM Get servers hostname for SERVER:
for /F "usebackq" %%i in (`hostname`) do set SERVER=%%~i
echo server=%SERVER%

REM Setup needed variables:
set SERVICE="Apache2.4"
set SERVICELOC=local


REM set Script Path
set SCRIPTPATH=C:\Scripts


@echo *********************************************************************************************************
@echo Starting Archive Process
@echo *********************************************************************************************************

REM 1) Stop Apache Windows Service
if /I "!RESTARTAPACHE!" EQU "yes" (
  @echo Stopping %SERVICE% Windows Service
  @echo PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "stop" %SERVICE% %SERVER% "local"
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "stop" %SERVICE% %SERVER% "local"
)


REM Get the Current date as MM-dd-yyyy format and set Zip File Name
REM for /f %%a in ('powershell -Command "Get-Date -format MM-dd-yyyy"') do set mmddyyyy=%%a

REM Call Python Script:
@echo calling %HTTP_HOME%\usrbin\Python\ArchiveApacheLogs.py %LOGDIR% %ZIPFILE%
@echo PYTHON_HOME = %PYTHON_HOME%
call %PYTHON_HOME%\python %HTTP_HOME%\usrbin\Python\ArchiveApacheLogs.py %RESTARTAPACHE%

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


REM 5) Start Apache Windows service.
if /I "!RESTARTAPACHE!" EQU "yes" (
  @echo Starting %SERVICE% Windows Service
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "start" %SERVICE% %SERVER% "local"
)

:optional
REM OPTIONAL:
REM 6) Delete Archived log files (more than 30 days old).
if NOT "!PURGE!"=="" (
@echo purging files older than %PURGE% days.

  echo %PURGE%| findstr /r "^[1-9][0-9]*$">nul
  if %errorlevel% equ 0 (
    REM PURGE contains a valid number - Do purge:
	@echo Purging archived root log files for Apache that are older than %PURGE% days	
	PowerShell -Command "Get-ChildItem '%ROOTARCHIVELOGDIR%' | Where {$_.lastwritetime -lt (Get-Date).AddDays(-%PURGE%)} | Remove-Item -Force -ErrorAction SilentlyContinue"
	
	@echo Purging archived security log files for Apache that are older than %PURGE% days	
	PowerShell -Command "Get-ChildItem '%SECURITYARCHIVELOGDIR%' | Where {$_.lastwritetime -lt (Get-Date).AddDays(-%PURGE%)} | Remove-Item -Force -ErrorAction SilentlyContinue"	
  )
  
)

@echo *********************************************************************************************************
@echo Finished Archive Process
@echo *********************************************************************************************************

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: ArchiveApacheLogs.bat arg1 arg2
echo arg1 = Should Apache be restarted (Example: yes)
echo arg2 (Optional) = Days Older than to Purge (Example: 30)
echo                   Note: This will purge any logs older than 30 days.

goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER% %ERRORMESSAGE%

REM END