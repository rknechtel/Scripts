
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: LinkProjectsStreams.bat
REM Author: Richard Knechtel
REM Date: 02/05/2021
REM Description: This script will allow you to link Coverity Projects to
REM              a "master" project for reporting.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM ************************************************************************

@echo.
@echo Running as user: %USERNAME%
@echo.

REM Set default Error Level
set ERRORLEVEL=0
set ERRORNUMBER=0
set ERRORMESSAGE=Success

REM Get parameters
@echo Parameters Passed = %1 %2 %3 %4 ********
@echo.
set HOST=%1
set PORT=%2
set PROJECT=%3
set USER=%4
set WAGWORD=%5

REM Check if we got ALL parameters
if "!HOST!"=="" goto usage
if "!PORT!"=="" goto usage
if "!PROJECT!"=="" goto usage
if "!USER!"=="" goto usage
if "!WAGWORD!"=="" goto usage
REM if "!HOST!"=="" if "!PORT!"=="" if "!PROJECT!"=="" if "!USER!"==""if "!WAGWORD!"=="" (
REM  goto usage
REM )


REM Setup needed variables:
REM set Script Path
set SCRIPTPATH=D:\Scripts

@echo.
@echo *********************************************************************************************************
@echo Starting Process of linking all projects in Coverity to "master" project
@echo *********************************************************************************************************
@echo.

REM Python Version:
@echo PYTHON_HOME = %PYTHON_HOME%
@echo.
@echo calling D:\Scripts\Coverity\Synopsys\wsLinkStreams.py
call %PYTHON_HOME%\python %SCRIPTPATH%\Coverity\Synopsys\wsLinkStreams.py  --host %HOST% --port %PORT% --ssl --project %PROJECT% --password %WAGWORD% --user %USER%

@echo.
@echo error level=%ERRORLEVEL%
@echo.
if %ERRORLEVEL% NEQ 0 (
  @echo Linking of Projects Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Linking of Projects Failed.
) else (
  @echo Linking of Projects  Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Linking of Projects  Succeeded.
)

@echo.
@echo *********************************************************************************************************
@echo Finished Process of linking all projects in Coverity to "master" project
@echo *********************************************************************************************************
@echo.

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
set ERRORMESSAGE= Invalid Usage
echo [USAGE]: LinkProjectsStreams.bat arg1 arg2 arg3 arg4 arg5
echo arg1 = Host (Coverity Server) (Example: MC21QWIN796)
echo arg2 = Port (SSL Port Number) (Example: 8443)
echo arg3 = Project Name to Link projects to (Example: AllProjects)
echo arg4 = Username of User with authority to perform this operation (Example: MyAdminID)
echo arg5 = Password of User with authority to perform this operation (Example: MyAdminPassword)
goto getoutofhere


:getoutofhere
@echo.
@echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORNUMBER% %ERRORMESSAGE%

REM END
