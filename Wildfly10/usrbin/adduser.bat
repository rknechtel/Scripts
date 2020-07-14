
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script Name: adduser.bat
REM Description: Add a user to a specific App Server Instance
REM Author: Richard Knechtel
REM Date: 06/08/2016
REM
REM Parameters:
REM AppSrvxx
REM Management User ID
REM Management User Password
REM RBAC Role: Role (Optional)(Defaults to SuperUser)
REM
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set APPSRV=%1
set USERID=%2
set PASSWORD=%3
set ROLE=%4

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage
if "!USERID!"=="" goto usage
if "!PASSWORD!"=="" goto usage
if "!APPSRV!"=="" if "!USERID!"=="" if "!PASSWORD!"=="" (
   goto usage
)

if "!ROLE!"=="" set ROLE=SuperUser

@echo RBAC Role =  %ROLE%

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Uncomment to override standalone and domain user location
REM use for adding to domain management user/group properties files:
REM set "JAVA_OPTS=%JAVA_OPTS% -Djboss.server.config.user.dir= -Djboss.domain.config.user.dir=..\domain\configuration"
REM Use for adding to sepcific App Server Instance management user/group properties files:
REM set "JAVA_OPTS=%JAVA_OPTS% -Djboss.server.config.user.dir=%JBOSS_HOME%\%APPSRV%\\configuration -Djboss.domain.config.user.dir=%JBOSS_HOME%\%APPSRV%\\configuration"
set JAVA_OPTS=%JAVA_OPTS% -Djboss.server.config.user.dir=%JBOSS_HOME%\%APPSRV%\configuration -Djboss.domain.config.user.dir=%JBOSS_HOME%\%APPSRV%\configuration
call %JBOSS_HOME%\bin\add-user.bat %USERID% %PASSWORD% -g %ROLE%

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: adduser.bat arg1 ag2 arg3 arg4
echo arg1 = AppSrv Instance Name (Example: AppSrv01) 
echo arg2 = Management User ID (Example: MyAdminID) 
echo arg3 = Management User Password (Example: My@dm1nP@$$w0rd) 
echo arg4 = RBAC Role (Example: SuperUser) (Options are: Monitor,Operator,Maintainer,Deployer,Auditor,Administrator,SuperUser(default)) (Optional)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
