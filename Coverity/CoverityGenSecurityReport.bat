
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: CoverityGenSecurityReport.bat
REM Author: Richard Knechtel
REM Date: 12/10/2020
REM Description: This script will run the Coverity Security Report
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM             Coverity Project Name (Name of project in Coverity)
REM             Coverity Severity (Allowed Values: VeryHigh, High, Medium, Low, VeryLow)
REM             Report Path (Optional: path to where Security Report PDF file should go
REM                                    if not passed will put in a default location)
REM             Coverity Password (For querying issues in Coverity)
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
set COVERITYPROJECTNAME=%1
set COVERITYSEVERITY=%2

REM %3 / REPORTPATH is optional - if empty we will set it with a default
set REPORTPATH=NULL
set REPORTPW=NULL

if "%~4"=="" (
  set REPORTPATH=
  set REPORTPW=%3
) else (
  set REPORTPATH=%3
  set REPORTPW=%4
)

echo.
echo Parameters Passed: 
echo Coverity Project Name: %COVERITYPROJECTNAME% 
echo Coverity Severity: %COVERITYSEVERITY% 
echo Coverity Report Path: %REPORTPATH%
echo ReportPW = %REPORTPW%
echo.

REM Check if we got ALL required parameters
if "!COVERITYPROJECTNAME!"=="" goto usage
if "!COVERITYSEVERITY!"=="" goto usage
if "!REPORTPW!"=="" goto usage
if "!COVERITYPROJECTNAME!"=="" if "!COVERITYSEVERITY!"=="" if "!REPORTPW!"=="" (
   goto usage
)

REM Set Coverity Reports program path:
REM On Server:
REM set COVREPORTSPATH="D:\Program Files\Coverity\CovReports"
REM With Directory Junction: mklink /J D:\Coverity "D:\Program Files\Coverity"
REM set COVREPORTSPATH=D:\Coverity\CovReports
REM With Mapped Drive
REM set COVREPORTSPATH=S:\CovReports
REM UNC Path
set COVREPORTSPATH=\\COVERITYSERVER\coverity\CovReports

if "!REPORTPATH!"=="" (
  REM Reports Path (where PDF reports should go)
  REM On Server:
  REM set REPORTPATH="D:\Program Files\Coverity\SecurityReports"
  REM With Directory Junction: mklink /J D:\Coverity "D:\Program Files\Coverity"
  REM set REPORTPATH=D:\Coverity\SecurityReports
  REM With Mapped Drive:
  REM set REPORTPATH=S:\SecurityReports
  REM Use UNC Path
  set REPORTPATH=\\COVERITYSERVER\coverity\SecurityReports
)



REM Report Date: formatted as YYYY-MM-DD
REM Get the Current date as yyyy-mm-dd_HH-mm-ss format and set our report date.
REM for /f %%a in ('powershell -Command "Get-Date -format yyyy-MM-dd_HH-mm-ss"') do set yyyymmddhhmmss=%%a
REM Get the Current date as yyyy-mm-dd format and set our report date.
for /f %%a in ('powershell -Command "Get-Date -format yyyy-MM-dd"') do set yyyymmdd=%%a
set REPORTDATE=%yyyymmdd%
@echo ReportDate = %REPORTDATE%

REM Set Default Error Number and Error Message
set ERRORNUMBER=0
set ERRORMESSAGE=Successful

REM Verify the Severity passed in is on of the valid values - Allowed Values: VeryHigh, High, Medium, Low, VeryLow
echo setting SEVERITYLIST
set SEVERITYLIST=VeryHigh High Medium Low VeryLow
echo checking if %COVERITYSEVERITY% is in Severity List
for %%i in (%SEVERITYLIST%) do (
  if %%i==%COVERITYSEVERITY% (
    REM echo Severity %COVERITYSEVERITY% was found
    goto myloopbreak
  ) else (
     echo ERROR: Severity %COVERITYSEVERITY% was not found. Please select from: VeryHigh High Medium Low VeryLow
     set ERRORNUMBER=1
     set ERRORMESSAGE=Severity %COVERITYSEVERITY% is not valid.
     goto getoutofhere
    )
 )

:myloopbreak

REM Check if report file exists, if so delete old one before creating new one for the same date
@echo Checking if %REPORTPATH%\cov-security-report-%COVERITYPROJECTNAME%-%COVERITYSEVERITY%-%REPORTDATE%.pdf exists.
If exist "%REPORTPATH%\cov-security-report-%COVERITYPROJECTNAME%-%COVERITYSEVERITY%-%REPORTDATE%.pdf" (
  @echo %REPORTPATH%\cov-security-report-%COVERITYPROJECTNAME%-%COVERITYSEVERITY%-%REPORTDATE%.pdf exits - deleting
  @echo.
  del %REPORTPATH%\cov-security-report-%COVERITYPROJECTNAME%-%COVERITYSEVERITY%-%REPORTDATE%.pdf
)

REM Set Report PW - need to get from secure location (Admin PW)
set REPORT_PW=%REPORTPW%

REM Run the Coverity Security Report
REM Report path on Coverity production server: D:\Coverity\SecurityReports
REM Share/Mount path on Build server: S:\SecurityReports
@echo Running Coverity Security Report with Severity %COVERITYSEVERITY% for Project %COVERITYPROJECTNAME%. Putting report into %COVERITYREPORTPATH%.
@echo command: %COVREPORTSPATH%\bin\cov-generate-security-report.exe "%COVREPORTSPATH%\config\ReportConfigs\config-CMIC-%COVERITYSEVERITY%.yaml" --on-new-cert trust --output "%REPORTPATH%\cov-security-report-%COVERITYPROJECTNAME%-%COVERITYSEVERITY%-%REPORTDATE%.pdf" --password env:REPORT_PW --project %COVERITYPROJECTNAME%
%COVREPORTSPATH%\bin\cov-generate-security-report.exe "%COVREPORTSPATH%\config\ReportConfigs\config-CMIC-%COVERITYSEVERITY%.yaml" --on-new-cert trust --output "%REPORTPATH%\cov-security-report-%COVERITYPROJECTNAME%-%COVERITYSEVERITY%-%REPORTDATE%.pdf" --password env:REPORT_PW --project %COVERITYPROJECTNAME%

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Running Coverity Security Report Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Running Coverity Security Report Failed.
)

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: CoverityGenSecurityReport.bat arg1 arg2 arg3 arg4
echo arg1 = Coverity Project Name (Example: MyApplication)
echo arg2 = Coverity Severity (Example: VeryHigh - Allowed Values: VeryHigh, High, Medium, Low, VeryLow))
echo arg3 = Coverity Report Path (Optional) (Example: D:\Reports)
echo arg4 = Report Password (Example: MySecretPassword)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
@echo.
@echo Your Security Report for %COVERITYPROJECTNAME% is located at: "%REPORTPATH%\cov-security-report-%COVERITYPROJECTNAME%-%COVERITYSEVERITY%-%REPORTDATE%.pdf.
@echo.
@echo Please take a copy of this for attaching to your Release and Change.
@echo.
Exit /B %ERRORNUMBER%
