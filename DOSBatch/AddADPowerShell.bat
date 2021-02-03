
@echo off
setlocal EnableExtensions EnableDelayedExpansion
REM *********************************************************************
REM Script: AddADPowerShell.bat
REM Author: Richard Knechtel
REM Date: 02/02/2021
REM Description: This will add the ActiveDirectory-PowerShell feature 
REM              if not enabled to the system
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM       This MUST be run as Administrator!!!
REM
REM *********************************************************************

echo Running as user: %USERNAME%
echo.
echo PLEASE NOTE: 
echo              This MUST be run as Administrator!!!
echo.

REM Check for ActiveDirectory-PowerShell feature
echo Checking for ActiveDirectory-PowerShell
REM Will return either "State : Disabled" or "State : Enabled"
for /f "tokens=*" %%i in ('dism /online /get-features ^| findstr "Feature Name : ActiveDirectory-PowerShell"') do set "isenabled=%%i"
echo isenabled=%isenabled%

REM Check if ActiveDirectory-PowerShell feature is disabled.
echo Checking if ActiveDirectory-PowerShell feature is disabled.
echo %isenabled% | findstr "Disabled" >Nul

if errorlevel 1 (
  REM ActiveDirectory-PowerShell feature not enabled - enabling
  echo "ActiveDirectory-PowerShell feature not enabled - enabling"
  dism /online /enable-feature /all /featurename:ActiveDirectory-PowerShell
) else (
  echo "ActiveDirectory-PowerShell feature is already enabled."
)

REM Lets get out of here!
goto getoutofhere



:getoutofhere
Exit /B %ERRORNUMBER%