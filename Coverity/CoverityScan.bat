@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: CoverityScan.bat
REM Author: Richard Knechtel
REM Date: 02/13/2020
REM Description: This script will run the Coverity command line 
REM              commands to scan a project and push defects to Coverity.
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
set PROJECTROOT=%1
set COVERITYSTREAMNAME=%2
set COVERITYSERVERNAME=%3
set COVERITYADMINID=%4
set COVERITYADMINPW=%5

echo.
echo Parameters Passed: 
echo Project Root: %PROJECTROOT% 
echo Coverity Stream Name: %COVERITYSTREAMNAME% 
echo Coverity Server Name: %COVERITYSERVERNAME%
echo Coverity Admin ID: %COVERITYADMINID%
echo Coverity Admin PW: **************
echo.

REM Check if we got ALL parameters
if "!PROJECTROOT!"=="" goto usage
if "!COVERITYSTREAMNAME!"=="" goto usage
if "!COVERITYSERVERNAME!"=="" goto usage
if "!COVERITYADMINID!"=="" goto usage
if "!COVERITYADMINPW!"=="" goto usage
if "!PROJECTROOT!"=="" if "!COVERITYSTREAMNAME!"=="" if "!COVERITYSERVERNAME!"=="" if "!COVERITYADMINID!"=="" if "!COVERITYADMINPW!"=="" (
   goto usage
)

REM Set Default Error Number and Error Message
set ERRORNUMBER=0
set ERRORMESSAGE=Successful

REM Save Starting Directory
set STARTDIR=%CD%

REM CD to project Root
@echo CD to %PROJECTROOT%
CD %PROJECTROOT%

REM Run the Coverity Build
@echo Running Coverity build [cov-build]
cov-build --dir idir mvn clean package

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Running Coverity build [cov-build] Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Running Coverity build [cov-build] Failed - exiting.
  goto getoutofhere
) else (
  @echo Running Coverity build [cov-build] Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Running Coverity build [cov-build] Succeeded. 
)

:CovAnalysis
REM Run the Coverity Analyize
@echo.
@echo Running Coverity Analyize [cov-analyze]
cov-analyze --dir idir --all --security --webapp-security

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Running Coverity Analyize [cov-analyze] Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Running Coverity Analyize [cov-analyze] Failed - exiting.
  goto getoutofhere
) else (
  @echo Running Coverity Analyize [cov-analyze] Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Running Coverity Analyize [cov-analyze] Succeeded. 
)

REM Run the Coverity Commit Defects
@echo Running Coverity Commit Defects [cov-commit-defects]
cov-commit-defects --dir idir --stream %COVERITYSTREAMNAME% --host %COVERITYSERVERNAME% --user %COVERITYADMINID% --password %COVERITYADMINPW% --dataport 9090

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Running Coverity Commit Defects [cov-commit-defects] Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Running Coverity Commit Defects [cov-commit-defects] Failed - exiting.
  goto getoutofhere
) else (
  @echo Running Coverity Commit Defects [cov-commit-defects] Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Running Coverity Commit Defects [cov-commit-defects] Succeeded. 
)

REM Removing idir - so it's not comitted to SVN/GIT
@echo Removing idir - so it's not comitted to SVN/GIT
REm Gives: The directory is not empty.
REM rmdir -r idir
REM So use:
move idir D:\
rmdir /s /q D:\idir

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Removing idir - so it's not comitted to SVN/GIT Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Removing idir - so it's not comitted to SVN/GIT Failed - exiting.
  goto getoutofhere
) else (
  @echo Removing idir - so it's not comitted to SVN/GIT Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Removing idir - so it's not comitted to SVN/GIT Succeeded. 
)


REM CD back to starting directory
@echo CD to %STARTDIR%
CD %STARTDIR%

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: CoverityScan.bat arg1 arg2 arg3 arg4 arg5
echo arg1 = Project Root (Example: D:\Projects\MyApplication)
echo arg2 = Coverity Stream Name (Example: MyApplication)
echo arg3 = Coverity Server Name (Example: MC21PWIN908)
echo arg4 = Coverity Admin ID (Example: Administrator)
echo arg5 = Coverity Admin ID Password (Example: Adm1nP@$$w0rd)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
@echo.
@Echo CoverityScan.bat ended. ERRORNUMBER = %ERRORNUMBER% ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORNUMBER%
