
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: BackupSonarMySQL.bat
REM Author: Richard Knechtel
REM Date: 02/13/2019
REM Description: This script will allow you to backup the SonarCube
REM              MySQL Database
REM
REM Notes:
REM   Must be run as Administrator!!
REM
REM ************************************************************************

@echo.
@echo ******************************************
@echo This script MUST be run as Administrator.
@echo ******************************************
@echo.
@echo Running as user: %USERNAME%
@echo.

REM Get parameters
@echo Parameters Passed = %1 %2
@echo.
set USERID=%1
set PASSWORD=%2


REM Check if we got ALL parameters
if "!USERID!"=="" goto usage
if "!PASSWORD!"=="" goto usage
if "!USERID!"=="" if "!PASSWORD!"=="" (
  goto usage
)


REM Set default Error Level
set ERRORLEVEL=0
set ERRORMESSAGE=Success

REM set Script Path
set SCRIPTPATH=D:\Scripts

@echo 

@echo *********************************************************************************************************
@echo Starting Backup Process
@echo *********************************************************************************************************


REM Get the Current date as MM-dd-yyyy-HH-mm-mm format to add to the backup File Name
for /f %%a in ('powershell -Command "Get-Date -format MM-dd-yyyyTHH-mm-ss"') do set mmddyyyyhhmmss=%%a

set SONARLOCATION="C:\Program Files\MySQL\MySQL Server 5.7\bin"
set SONARDATABACKUPS="C:\ProgramData\MySQL\MySQL Server 5.7\DataBackups"

set BACKUPFILENAME=SonarCubeBackup-%mmddyyyyhhmmss%.sql
@echo Backup File Name = %BACKUPFILENAME%

"%SONARLOCATION%\mysqldump.exe" -u %USERID% -p %PASSWORD% --quick --lock-tables=false --all-databases > "%SONARDATABACKUPS%\"%BACKUPFILENAME%

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Backup Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Backup Failed.
) else (
  @echo Backup Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Backup Succeeded.
)



@echo *********************************************************************************************************
@echo Finished Backup Process
@echo *********************************************************************************************************

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: BackupSonarMySQL.bat arg1 arg2
echo arg1 = MySQL UserID (Example: MySQLID)
echo arg2 = MySQL UserID Password (Example: MyPassword)

goto getoutofhere

:getoutofhere
@echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORNUMBER% %ERRORMESSAGE%

REM END
