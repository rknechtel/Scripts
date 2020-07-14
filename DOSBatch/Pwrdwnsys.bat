
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: Pwrdwnsys.bat
REM Author: Richard Knechtel
REM Date: 04/09/2017
REM Description: This script will allow you to:
REM              Shutdown, Reboot, Hibernate or Logoff your system.
REM License: Copyleft
REM 
REM Notes:
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
set COMMAND=%1

REM Set default Error Level
set ERRORLEVEL=0

REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage

if /I "%COMMAND%" == "lock" goto cmdLockWorkstation
if /I "%COMMAND%" == "shutdown" goto cmdShutdown
if /I "%COMMAND%" == "reboot" goto cmdReboot
if /I "%COMMAND%" == "hibernate" goto cmdHibernate
if /I "%COMMAND%" == "sleep" goto cmdSleep
if /I "%COMMAND%" == "logoff" goto cmdLogoff

:cmdLockWorkstation
Rundll32.exe User32.dll,LockWorkStation
REM Lets get out of here!
goto getoutofhere

:cmdShutdown
REM Shutdown
%windir%\System32\shutdown.exe -s

:cmdReboot
REM Reboot
%windir%\System32\shutdown.exe -r
REM Lets get out of here!
goto getoutofhere

:cmdHibernate
REM Hibernate
REM %windir%\System32\shutdown.exe -h
%windir%\System32\rundll32.exe PowrProf.dll,SetSuspendState
REM Lets get out of here!
goto getoutofhere

:cmdSleep
%windir%\System32\rundll32.exe powrprof.dll,SetSuspendState 0,1,0
REM Lets get out of here!
goto getoutofhere

:cmdLogoff
REM Logoff
%windir%\System32\shutdown.exe -l
REM Lets get out of here!
goto getoutofhere


REM ****************************************************************************
REM Usage
REM ****************************************************************************
:usage
set ERRORLEVEL=1
echo [USAGE]: Pwrdwnsys.bat arg1
echo arg1 = Command (Options: alock,shutdown,reboot,hibernate,sleep,logoff)

goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORLEVEL%