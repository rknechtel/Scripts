@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: setenvvars2.bat
REM Author: Richard Knechtel
REM Date: 05/08/2017
REM Description: This script will Setup all Environment Variables for a
REM              Apache server
REM
REM
REM Note: This script MUST be run as ADMINISTRATOR!
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.
echo Note: This script MUST be run as ADMINISTRATOR!
echo.

REM These must be done after sentenvars.bat is run.

REM Verify the ENV Vars were set by sentenvars.bat
echo JAVA_HOME = %JAVA_HOME%
echo OPENSSL_HOME = %OPENSSL_HOME%

REM Set up OPENSSL_CONF
setX OPENSSL_CONF "%OPENSSL_HOME%\bin\openssl.cfg" /m

REM Set up CLASSPATH
setX CLASSPATH "%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\jre\lib\rt.jar;" /m

REM Set up PATH
setX PATH "%PATH%;%JAVA_HOME%\bin;" /m

REM Lets get out of here!
goto getoutofhere


REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORLEVEL%