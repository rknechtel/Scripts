@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: SnapshotConfig.bat
REM Author: Richard Knechtel
REM Date: 10/10/2016
REM Description: This script will allow you to 
REM              Take/List/Delete Configuration File Snapshots.
REM
REM Parameters:
REM            Command (Example: take/list/delete)
REM            AppSrv Instance Name (Example: AppSrv01)
REM 
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set COMMAND=%1
set APPSRV=%2
set SNAPSHOTNAME=%3

REM Set default Error Number
set ERRORNUMBER=0

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage
if "!APPSRV!"=="" goto usage
if "!COMMAND!"=="" if "!APPSRV!"=="" (
  goto usage
)
REM If COMMAND = "delete" then MUST have param %3 (SNAPSHOTNAME) - if SNAPSHOTNAME = "all" - remove all of them.
if "!COMMAND!"=="delete" if "!SNAPSHOTNAME!"=="" (
  goto usage
)



if /I "%COMMAND%" == "take"     goto cmdTake
if /I "%COMMAND%" == "list"      goto cmdList
if /I "%COMMAND%" == "delete"      goto cmdDelete

REM Take a Snapshot of a Configuration file:
:cmdTake
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=":take-snapshot"

REM Lets get out of here!
goto getoutofhere

REM List the Snapshots of a Configuration file:
:cmdList
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=":list-snapshots"

REM Lets get out of here!
goto getoutofhere

REM Delete the Snapshot(s) of a Configuration file:
:cmdDelete
%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=":delete-snapshot(name="%SNAPSHOTNAME%")"

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: SnapshotConfig.bat arg1 arg2 arg3
echo arg1 = Command (take/list/delete)
echo arg2 = AppSrv Instance Name (Example: AppSrv01)
echo arg3 (Optional) = Name of Snapshot to remove 
echo                  (Example: 20140814-234725965standalone-full-ha.xml for a specific snapshot) 
echo                  OR ( all for ALL snapshots )
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%