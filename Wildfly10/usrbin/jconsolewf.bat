
@echo off
REM ************************************************************************
REM Script Name: jconsolewf.bat
REM Author: Richard Knechtel
REM Date: 01/19/2018
REM Description: Runs the jconsole GUI for Wildfly
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Or use the jconsole.bat in:
REM %JBOSS_HOME%\bin\jconsole.bat
REM %JBOSS_HOME%\bin\jconsole.ps1
REM $JBOSS_HOME/bin/jconsole.sh
REM
REM Parameters:
REM             NONE
REM
REM For HTTP Use:
REM service:jmx:http-remoting-jmx://[HOST]:[PORT]
REM
REM For HTTPS Use:
REM service:jmx:https-remoting-jmx://[HOST]:[PORT]
REM
REM Note: Port number MUST include port offset!
REM 
REM Example URL's (for a local AppSrv01):
REM             HTTP:   service:jmx:http-remoting-jmx://localhost:10090
REM             HTTPS:  service:jmx:https-remoting-jmx://localhost:10093
REM
REM USER ID: Use a Wildfly Management User ID
REM Password: Use a Wildfly Management User Password
REM
REM ************************************************************************

echo Running as user: %USERNAME%


REM Set default Error Number
set ERRORNUMBER=0


%JAVA_HOME%\bin\jconsole -J-Djava.class.path=%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\lib\jconsole.jar;C:\opt\wildfly-10.1.0.Final\bin\client\jboss-cli-client.jar

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: jconsole.bat
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
