@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: setenvvars.bat
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


REM Set up HTTP_HOME
setX HTTP_HOME "D:\opt\Apache24" /m

REM Set up JAVA_HOME
setX JAVA_HOME "D:\opt\Java\jdk1.8.0_45" /m

REM Set up PYTHON_HOME
setX PYTHON_HOME "D:\opt\Python34" /m

REM Set up OPENSSL_HOME
setX OPENSSL_HOME "D:\opt\OpenSSL-Win64" /m

REM These must be done after the above are done.
REM Set up OPENSSL_CONF
REM Set up CLASSPATH
REM Set up PATH
REM This will set the other Env Vars in a new command prompt and exit it.
call "cmd /c start setenvvars2.bat"

REM Lets get out of here!
goto getoutofhere


REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORLEVEL%