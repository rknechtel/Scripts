@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: setenvvars.bat
REM Author: Richard Knechtel
REM Date: 05/08/2017
REM Description: This script will Setup all Environment Variables for a
REM              Middleware/Wildfly server
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
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

REM Set up JBOSS_HOME (Change Directory Junction for each Wildfly Upgrade)
setX JBOSS_HOME "D:\opt\Wildfly" /m

REM Eliminate the "Press any key to continue" for batch processing
setX NOPAUSE "1" /m

REM Set up WILDFLY10_HOME
setX WILDFLY10_HOME "D:\opt\wildfly-10.1.0.Final" /m

REM Set up JYTHON_HOME
setX JYTHON_HOME "D:\opt\Jython" /m

REM Set up PYTHON_HOME
setX PYTHON_HOME "D:\opt\Python34" /m

REM Setup SAXON_HOME - needed for XSLT transformations in AppInstanceTemplate
setX SAXON_HOME "D:\opt\Saxon" /m

REM Set up OPENSSL_HOME
setX OPENSSL_HOME "D:\opt\OpenSSL-Win64" /m

REM These must be done after the above are done.
REM Set up OPENSSL_CONF
REM Set up CLASSPATH
REM Set up PATH
REM This will set the other Env Vars in a new command prompt and exit it.
call "cmd /c start setenvvars2.bat"


REM Set up OPENSSL_CONF
REM setX OPENSSL_CONF "%OPENSSL_HOME%\bin\openssl.cfg" /m

REM Set up CLASSPATH
REM setX CLASSPATH "%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\jre\lib\rt.jar;%%JYTHON_HOME%\jython.jar;JBOSS_HOME%\bin\client\jboss-cli-client.jar" /m

REM Set up PATH
REM setX PATH "%PATH%;%JAVA_HOME%\bin;%JYTHON_HOME%\bin;%JBOSS_HOME%\bin;%JBOSS_HOME%\usrbin;" /m

REM Lets get out of here!
goto getoutofhere


REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORLEVEL%