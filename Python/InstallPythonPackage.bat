@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: InstallPythonPackage.bat
REM Author: Richard Knechtel
REM Date: 02/27/2020
REM Description: This will install new python packages
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM *********************************************************************

echo Running as user: %USERNAME%
echo.

set PYTHONPACKAGE=%1

REM Check if we got ALL parameters
if "!PYTHONPACKAGE!"=="" goto usage

python -m pip install %PYTHONPACKAGE%

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: InstallPythonPackage.bat arg1
echo arg1 = Python Package (Example: python-ldap)
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%