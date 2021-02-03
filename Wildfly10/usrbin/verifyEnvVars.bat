
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: verifyEnvVars.bat
REM Author: Richard Knechtel
REM Date: 07/01/2019
REM Description: This script verify if environment Variables were set.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Verify the ENV Vars were set by sentenvars.bat / sentenvars2.bat
echo.
echo Verify All Environment Variables were set.
echo.
echo CLASSPATH = %CLASSPATH%
echo HTTP_HOME = %HTTP_HOME%
echo JAVA_HOME = %JAVA_HOME%
echo JBOSS_HOME = %JBOSS_HOME%
echo JYTHON_HOME = %JYTHON_HOME%
echo NOPAUSE = %NOPAUSE%
echo OPENSSL_HOME = %OPENSSL_HOME%
echo OPENSSL_CONF = %OPENSSL_CONF%
echo PATH = %PATH%
echo PYTHON_HOME = %PYTHON_HOME%
echo SAXON_HOME = %SAXON_HOME%
echo WILDFLY10_HOME = %WILDFLY10_HOME%

 
