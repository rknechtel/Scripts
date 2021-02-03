
@echo off
setlocal enableDelayedExpansion
REM *******************************************************************
REM Script Name: CreateAppInstance.bat
REM Author: Richard Knechtel 
REM Date: 12/02/2015
REM Description: This will create a new Wildfly App Server Instance 
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM            Next AppSrv number
REM            Host Name To Change
REM            Port Offset (use increments of 100, so server instance number is 02 - port offset would be 200)
REM
REM *******************************************************************

REM @echo on

echo Running as user: %USERNAME%

set ERRORNUMBER=0

REM Get next AppSrvXX number
set APPSRVNUM=%1

REM Get hostname
set CHANGEHOSTNAME=%2
REM To get dynamically:
REM FOR /F "usebackq" %%i IN (`hostname`) DO SET CHANGEHOSTNAME=%%i

REM get Port Offset
set PORTOFFSET=%3

REM Original: <socket-binding-group name="standard-sockets" default-interface="public" port-offset="${jboss.socket.binding.port-offset:100}">
set PORTOFFSETORIGINAL=jboss.socket.binding.port-offset:100
set PORTOFFSETNEW=jboss.socket.binding.port-offset:%PORTOFFSET%


REM Check if we got BOTH parameters
if "!APPSRVNUM!"=="" goto usage
if "!CHANGEHOSTNAME!"=="" goto usage
if "!PORTOFFSET!"=="" goto usage
if "!APPSRVNUM!"=="" if "!CHANGEHOSTNAME!"=="" if "!PORTOFFSET!"=="" (
  goto usage
)

REM Copy the Template to new app server instance number into JOBSS_HOME
echo copying Template directory
xcopy /E %JBOSS_HOME%\AppInstanceTemplate\AppSrvXX\*.* %JBOSS_HOME%\AppSrv%APPSRVNUM%\*.*


REM Rename the AppSrvXX-full.xml file
echo moving: %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrvXX-full.xml TO %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrv%APPSRVNUM%-full.xml
move %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrvXX-full.xml %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrv%APPSRVNUM%-full.xml

REM Reaplce all occurences of localhost with %CHANGEHOSTNAME%
echo searching and replacing all occurences of localhost with %CHANGEHOSTNAME% in %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrv%APPSRVNUM%-full.xml
powershell -Command "(gc %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrv%APPSRVNUM%-full.xml) -replace 'localhost', '%CHANGEHOSTNAME%' | Out-File %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrv%APPSRVNUM%-full.xml"


REM Update Port Offset:
echo Updating Port Offset. Original=%PORTOFFSETORIGINAL% New=%PORTOFFSETNEW%
powershell -Command "(gc %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrv%APPSRVNUM%-full.xml) -replace '%PORTOFFSETORIGINAL%', '%PORTOFFSETNEW%' | Out-File %JBOSS_HOME%\AppSrv%APPSRVNUM%\configuration\AppSrv%APPSRVNUM%-full.xml"


REM Update ToStartServer.txt
echo Updating ToStartServer.txt
powershell -Command "(gc %JBOSS_HOME%\AppSrv%APPSRVNUM%\ToStartServer.txt) -replace 'AppSrv01', 'AppSrv%APPSRVNUM%' | Out-File -encoding ASCII %JBOSS_HOME%\AppSrv%APPSRVNUM%\ToStartServer.txt"


REM copy vault.keystore to new instance if exists - overwrite
echo copying valut.keystore
if "!APPSRVNUM!" GTR "01" (
  copy /Y %JBOSS_HOME%\AppSrv01\vault\vault.keystore %JBOSS_HOME%\AppSrv%APPSRVNUM%\vault\*
)

REM Need to add entry in jboss-cli.xml
echo TODO: Need to add Controller Alias in JBOSS_HOME\bin\jboss-cli.xml for AppSrv%APPSRVNUM%.

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: CreateAppInstance.bat arg1 arg2 arg3
echo arg1 = (Next AppSrv number) (Possible values: 02 - XX)
echo arg2 = (Host Name To Change) (Can use Host Name, Alias or IP Address)
echo arg2 = Port Offset (use increments of 100, so server instance number is 02 - port offset would be 200)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%