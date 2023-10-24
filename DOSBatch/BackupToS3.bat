@echo off

setlocal EnableDelayedExpansion

@REM *********************************************************************
@REM Script: BackupToS3.bat
@REM Author: Richard Knechtel
@REM Date: 10/23/2023
@REM Description: This will backup/sync to S3:
@REM
@REM LICENSE: 
@REM This script is in the public domain, free from copyrights or restrictions.
@REM
@REM Parameters: 
@REM             Path to Backup
@REM             S3 Path to Backup To
@REM             Log File Path
@REM
@REM NOTE: This uses the AWS CLI
@REM Ref:
@REM https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
@REM Ref:
@REM https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/sync.html
@REM
@REM *********************************************************************

echo Running as user: %USERNAME% >> %LOGFILE%

REM Get parameters
@echo Parameters Passed = %~f1 %2 %~f3 >> %LOGFILE%

SET PATHTOBACKUP=%~f1
SET S3PATHTOBACKUPTO=%2
SET LOGFILE=%~f3

REM Check if we got ALL parameters
if "!PATHTOBACKUP!"=="" goto usage
if "!S3PATHTOBACKUPTO!"=="" goto usage
if "!LOGFILE!"=="" goto usage
if "!PATHTOBACKUP!"=="" if "!S3PATHTOBACKUPTO!"=="" if "!LOGFILE!"=="" (
   goto usage
)

@REM Get Local Date/Time
@echo off
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo Backup of %PATHTOBACKUP% Started at: [%ldt%] >> %LOGFILE%
aws s3 sync %PATHTOBACKUP% %S3PATHTOBACKUPTO% --storage-class STANDARD_IA --region us-east-1 >> %LOGFILE%

@REM Get Local Date/Time
@echo off
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo Backup of %PATHTOBACKUP% Finished at: [%ldt%] >> %LOGFILE%

goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: BackupToS3.bat arg1 arg2 arg3 >> %LOGFILE%
echo arg1 = Path To Backup (Example: E:\MyApp\MyAppData) >> %LOGFILE%
echo arg2 = S3 Path To Backup To (Example: s3://MyApp/DEV/MyAppData) >> %LOGFILE%
echo arg3 = Full path for log file (Example: E:\Logs\S3Sync.log) >> %LOGFILE%

goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
