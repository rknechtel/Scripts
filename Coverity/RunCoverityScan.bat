@echo off

setlocal EnableDelayedExpansion

REM ************************************************************************
REM Script: RunCoverityScan.bat
REM Author: Richard Knechtel
REM Date: 11/20/2019
REM Description: This script will run a Coverity scan on the Java project
REM              directory this script is run from.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Make sure On Coverity Server Share is setup:
REM New-SmbShare –Name Coverity –Path "D:\Program Files\Coverity\"
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

echo Pass Parameters: %1 %2 %3 %4 %5 %6 %7

REM Get parameters
set PROJECT=%1
set PROJECTPATH=%2
set BUILDCOMMAND=%3
set IDIR=%4
set USERID=%5
set PASSWORD=%6
set CHECKERS=%7

REM Check if we got ALL REQUIRED parameters
if "!PROJECT!"=="" goto usage
if "!PROJECTPATH!"=="" goto usage
if "!BUILDCOMMAND!"=="" goto usage
if "!IDIR!"=="" goto usage
if "!PROJECT!"=="" if "!PROJECTPATH!"=="" if "!BUILDCOMMAND!"=="" if "!IDIR!"=="" (
   goto usage
)


REM Setup Coverity Environment Variables

REM Map to Server Network Share
REM net use Z: \\<SERVERNAME>\Coverity
REM Changed to use PowerShell SmbMapping command as net use was hanging DOS in Windows 2012 R2
powershell -ExecutionPolicy Bypass -Command "New-SMBMapping -LocalPath 'Z:' -RemotePath '\\<SERVERNAME>\Coverity'"

set COVARITY_HOME=Z:\CovStatAnalysis
echo COVARITY_HOME = %COVARITY_HOME%
REM set PATH=D:\opt\Java\jdk1.8.0_45\bin;D:\Apache\apache-maven-3.2.5\bin;D:\Apache\apache-ant-1.9.6\bin;%COVARITY_HOME%\bin
echo PATH = %PATH%

REM Setup Checkers:
if "!CHECKERS!"=="" (
  set CHECKERS=--all --security --webapp-security

)

echo CHECKERS = %CHECKERS%

REM Get current directory:
set CURRENTDIR=%CD%
echo Current Directory = %CURRENTDIR%

REM Remove IDIR
echo Removing %IDIR%
rd /s /q %IDIR%

REM Remove quotes from passed in Build Command
CALL :dequote BUILDCOMMAND
Echo BUILDCOMMAND = %BUILDCOMMAND%

REM Change to Project Path:
Echo PROJECTPATH = %PROJECTPATH%
cd %PROJECTPATH%

REM Run cov-build
echo Running: cov-build --dir %IDIR% %BUILDCOMMAND%
cov-build --dir %IDIR% %BUILDCOMMAND%

REM Run cov-analyze
echo Running: cov-analyze --dir %IDIR% %CHECKERS%
cov-analyze --dir %IDIR% %CHECKERS%

REM Run cov-commit-defects
echo Running: cov-commit-defects --dir %IDIR% --stream %PROJECT% --host MC21QWIN796 --user %USERID% --password %PASSWORD% --dataport 9090
cov-commit-defects --dir %IDIR% --stream %PROJECT% --host MC21QWIN796 --user %USERID% --password %PASSWORD% --dataport 9090


REM Lets get out of here!
goto getoutofhere

:DeQuote
for /f "delims=" %%A in ('echo %%%1%%') do set %1=%%~A
Exit /B

:usage
set ERRORNUMBER=1
echo [USAGE]: RunCoverityScan.bat arg1 arg2 arg3 arg4 arg5 arg6 arg7
echo arg2 = Project (Example: MyApp)
echo arg2 = Project Path (Example: D:\Projects\MyApp)
echo arg3 = Build Command (Example: mvn clean package) 
echo arg4 = IDir (Example: D:\idir)
echo arg5 = UserId (Example: CM12345)
echo arg6 = Password (Example: MyPassword)
echo arg7 = Checkers (Example: --all --security --webapp-security) (optional - defaults to: --all --security --webapp-security)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere

REM Remove Drive Mapping
REM net use Z: /delete /Y
REM Changed to use PowerShell SmbMapping command as net use was hanging DOS in Windows 2012 R2
powershell -ExecutionPolicy Bypass -Command Remove-SmbMapping -LocalPath 'Z:' -Force"

REM Go back to starting directory
cd %CURRENTDIR%
set CURRENTDIR=%CD%
echo Back in Original Directory: %CURRENTDIR%

REM Exit Script
Exit /B %ERRORNUMBER%
