
@echo off
setlocal enableDelayedExpansion
REM ********************************************************************************
REM Script Name: CreateServiceScript.bat
REM Author: Richard Knechtel
REM Date: 02/03/2016
REM Description: This will create a new Wildfly App Server Windows Service Script 
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM            AppSrv number
REM
REM *******************************************************************************

REM @echo on


set ERRORNUMBER=0

REM Get AppSrvXX number
set APPSRVNUM=%1

REM Check if we got the parameter
if "!APPSRVNUM!"=="" goto usage
@echo off


REM Copy the service script template to
echo copying Template directory
copy %JBOSS_HOME%\bin\service\serviceAppSrvXX.bat %JBOSS_HOME%\bin\service\serviceAppSrv%APPSRVNUM%.bat

REM Reaplce all occurences of localhost with %CHANGEHOSTNAME% 
echo searching and replacing all occurences of AppSrvXX with AppSrv%APPSRVNUM% in %JBOSS_HOME%\bin\service\serviceAppSrv%APPSRVNUM%.bat
powershell -Command "(gc %JBOSS_HOME%\bin\service\serviceAppSrv%APPSRVNUM%.bat) -replace 'AppSrvXX', 'AppSrv%APPSRVNUM%' | Out-File -encoding ASCII %JBOSS_HOME%\bin\service\serviceAppSrv%APPSRVNUM%.bat"

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: CreateServiceScript.bat arg1 
echo arg1 = (Next AppSrv number) (Possible values: 01 - XX) 
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%