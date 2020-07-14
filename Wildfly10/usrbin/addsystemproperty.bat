@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: addsystemproperty.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will add a new system property
REM 
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM
REM       2) You must enclose any Property Values in double Quotes
REM          Example: "My AD Group"
REM ************************************************************************

echo Running as user: %USERNAME%
echo.
echo PLEASE NOTE: You must enclose any Property Values in double Quotes
echo              Example: "My AD Group"
echo.

REM Get parameters
set PROPERTY=%1
set PROPERTYVALUE=%2
set APPSRV=%3

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!PROPERTY!"=="" goto usage
if "!PROPERTYVALUE!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!PROPERTY!"=="" if "!PROPERTYVALUE!"=="" if "!APPSRV!"=="" (
  goto usage
)

REM Check if System Property already exists
echo Check for System Property: %PROPERTY% on %APPSRV%
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/system-property=%PROPERTY%:read-resource" | findstr success
IF %ERRORLEVEL% NEQ 0 (
  REM Add the new System Property
  echo The System Property: [ %PROPERTY% ] doesn't exist, Adding System Property: %PROPERTY% with a value of: %PROPERTYVALUE% on %APPSRV%
  %JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command="/system-property=%PROPERTY%:add(value="%PROPERTYVALUE%"))"
) ELSE (
  echo The System Property: [ %PROPERTY% ] already exists on %APPSRV%  
)



REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: addsystemproperty.bat arg1 arg2 arg3
echo arg1 = System Property
echo arg2 = System Property Value
echo arg3 = AppSrv Instance Name (Example: AppSrv01)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%