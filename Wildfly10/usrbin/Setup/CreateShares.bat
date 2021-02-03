
@echo off

setlocal EnableDelayedExpansion

REM ************************************************************************
REM Script: CreateShares.bat
REM Author: Richard Knechtel
REM Date: 09/28/2017
REM Description: This script will create the Windows shares for the 
REM ApplicationConfigurations and log directories for a Middleware/Wildfly 
REM server instance
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
echo       This script works ONLY on Server versions of Windows.
echo       For External Wildfly Servers REQUIRES 4th Patameter be: yes
echo.

REM Get parameters
set APPSRV=%1
set WFVERSION=%2
set SERVERNAME=%3
set EXTWF=%4

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage
if "!WFVERSION!"=="" goto usage
if "!SERVERNAME!"=="" goto usage
if "!APPSRV!"=="" if "!WFVERSION!"=="" if "!SERVERNAME!"=="" (
   goto usage
)

REM set Script Path
set SCRIPTPATH=%JBOSS_HOME%\usrbin\Setup

REM Call Powershell: SetSharePermissions.ps1 %APPSRV% %AppConfigNum% %WFVERSION%
@echo SetSharePermissions running - Script Path = %SCRIPTPATH%
if "!EXTWF!"=="" (
  echo Calling: "PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetSharePermissions.ps1 -ServerName %SERVERNAME% -AppSrvNumber %APPSRV% -WFVersion %WFVERSION%"
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetSharePermissions.ps1 -ServerName %SERVERNAME% -AppSrvNumber %APPSRV% -WFVersion %WFVERSION%
) else (
  echo Calling: PowerShell -ExecutionPolicy Bypass -Command %SCRIPTPATH%\SetSharePermissions.ps1 -ServerName %SERVERNAME% -AppSrvNumber %APPSRV% -WFVersion %WFVERSION% -EXTWF $True
  PowerShell -ExecutionPolicy Bypass -Command %SCRIPTPATH%\SetSharePermissions.ps1 -ServerName %SERVERNAME% -AppSrvNumber %APPSRV% -WFVersion %WFVERSION% -ExtWF $True
)

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: CreateShares.bat arg1 arg2 arg3 arg4
echo arg1 = AppSrv Instance Number (Example: 01) 
echo arg2 = Wildfly Version (Example: 10) 
echo arg3 = Server Name (Example: wildflydev)
echo arg4 = (Optional) External Wildfly (Must be lowercase: yes)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORNUMBER%