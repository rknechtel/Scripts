#!/bin/bash

##!/bin/sh

REM ************************************************************************
REM Script: deployment.bat
REM Author: Richard Knechtel
REM Date: 04/05/2015
REM Description: This script will allow you to do a Hot or Cold
REM              Deploy/Undeploy/Rollback of an application.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM   1) Need to have and AppSrv instance Alias configured in:
REM      %JBOSS_HOME%\bin\jboss-cli.xml
REM      Under <controllers>
REM
REM   2) Must be run as Administrator!!
REM      Because it needs admin authority for stopping/starting Windows services.
REM
REM   3) Example Call:
REM      deployment.bat deploy hot MyApp.war AppSrv01
REM 
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.
echo Note: This script ONLY supports applications WITHOUT version numbers in the name.
echo.

REM Get parameters
@echo Parameters Passed = %1 %2 %3 %4
set COMMAND=%1
set TYPE=%2
set APPLICATION=%3
set APPSRV=%4

REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage
if "!TYPE!"=="" goto usage
if "!APPLICATION!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!COMMAND!"=="" if "!TYPE!"=="" if "!APPLICATION!"=="" if "!APPSRV!"=="" (
  goto usage
)


REM Set default Error Level
set ERRORLEVEL=0
set ERRORMESSAGE=Success

REM Eliminate the "Press any key to continue"
set NOPAUSE=true


REM ****************************************************************************
REM Deploy Application
REM ****************************************************************************

@echo calling %PYTHON_HOME%\python %JBOSS_HOME%\usrbin\Python\Deployment.py %COMMAND% %TYPE% %APPLICATION% %APPSRV%

call %PYTHON_HOME%\python %JBOSS_HOME%\usrbin\Python\Deployment.py %COMMAND% %TYPE% %APPLICATION% %APPSRV%

@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo %COMMAND% of %APPLICATION% Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=%COMMAND% of %APPLICATION% Failed.
) else (
  @echo %COMMAND% of %APPLICATION% Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=%COMMAND% of %APPLICATION% Succeeded. 
)

REM Lets get out of here!
goto getoutofhere



REM ****************************************************************************
REM Usage
REM ****************************************************************************
:usage
set ERRORLEVEL=1
echo [USAGE]: Deployment.bat arg1 arg2 arg3 arg4
echo arg1 = Command (deploy / undeploy / rollback / polljboss)
echo arg2 = Type (hot / cold)
echo arg3 = Application (Example: MyApp.war)
echo arg4 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
@echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORLEVEL% %ERRORMESSAGE%
