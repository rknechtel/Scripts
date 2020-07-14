
@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: whois.bat
REM Author: Richard Knechtel
REM Date: 02/09/2018
REM Description: This will show who someone is by their Network ID
REM
REM *********************************************************************

set NETWORKID=%1

REM Check if we got ALL parameters
if "!NETWORKID!"=="" goto usage

@echo Showing information for %NETWORKID%:
@echo.
net user %NETWORKID% /domain


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: whois.bat arg1
echo arg1 = Network ID (Example: MYID012345)
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%
