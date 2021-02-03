@echo off
setlocal EnableDelayedExpansion EnableExtensions 
REM ************************************************************************
REM Script: CoverityGenSecurityReport.bat
REM Author: Richard Knechtel
REM Date: 12/15/2020
REM Description: This script will run the Coverity Security Report
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
set COVERITYPROJECTNAME=%1
set COVERITYSEVERITY=%2
set COVERITYREPORTPATH=%3
set REPORTPW=%4


echo.
echo Parameters Passed: 
echo Coverity Project Name: %COVERITYPROJECTNAME% 
echo Coverity Severity: %COVERITYSEVERITY% 
echo Coverity Report Path: %COVERITYREPORTPATH%
echo.

REM Check if we got ALL parameters
if "!COVERITYPROJECTNAME!"=="" goto usage
if "!COVERITYSEVERITY!"=="" goto usage
if "!COVERITYREPORTPATH!"=="" goto usage
if "!COVERITYPROJECTNAME!"=="" if "!COVERITYSEVERITY!"=="" if "!COVERITYREPORTPATH!"=="" (
   goto usage
)

REM Set Coverity Reports path:
REM On Server:
set COVREPORTSPATH="D:\Program Files\Coverity\CovReports"
REM With Directory Junction: mklink /J D:\Coverity "D:\Program Files\Coverity"
set COVREPORTSPATH=D:\Coverity\CovReports
REM With Mapped Drive
set COVREPORTSPATH=S:\CovReports

REM Reports Path
REM On Server:
set REPORTPATH="D:\Program Files\Coverity\SecurityReports"
REM With Directory Junction: mklink /J D:\Coverity "D:\Program Files\Coverity"
set REPORTPATH=D:\Coverity\SecurityReports
REM With Mapped Drive:
set REPORTPATH=S:\SecurityReports

REM Report Date: formatted as YYYY-MM-DD
REM Get the Current date as yyyy-mm-dd format and set our report date.
for /f %%a in ('powershell -Command "Get-Date -format yyyy-MM-dd"') do set yyyymmdd=%%a
set REPORTDATE=%yyyymmdd%
@echo ReportDate = %REPORTDATE%

REM Set Default Error Number and Error Message
set ERRORNUMBER=0
set ERRORMESSAGE=Successful

REM Verify the Severity passed in is on of the valid values - Allowed Values: VeryHigh, High, Medium, Low, VeryLow
REM echo setting SEVERITYLIST
REM set SEVERITYLIST=(VeryHigh High Medium Low VeryLow)
REM echo checking if %COVERITYSEVERITY% is in SEVERITYLIST
REM for %%i in (%SEVERITYLIST%) do (
REM   if %%i==%COVERITYSEVERITY% (
REM     echo Severity %COVERITYSEVERITY% was found
REM   ) else (
REM     echo Severity %COVERITYSEVERITY% was not found
REM     set ERRORNUMBER=1
REM     set ERRORMESSAGE=Severity %COVERITYSEVERITY% is not valid.
REM   )
REM )

REM Set Report PW - need to get from secure location if put in automated pipeline (Admin PW)
set REPORT_PW=%REPORTPW%

REM Run the Coverity Security Report
REM Report path on Coverity production server: S:\CovReports\Reports
@echo Running Coverity Security Report with Severity %COVERITYSEVERITY% for Project %COVERITYPROJECTNAME%. Putting report into %COVERITYREPORTPATH%.
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
echo arg3 = Coverity Report Path (Example: D:\Reports)
echo arg4 = Report Password (Example: MySecretPassword)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORNUMBER%