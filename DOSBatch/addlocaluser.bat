@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: addlocaluser.bat
REM Author: Richard Knechtel
REM Date: 05/18/2017
REM Description: This will add a local user to the system
REM
REM Notes:
REM       This MUST be run as Administrator!!!
REM       When passing in a Comment - pass it in with double Quotes
REM       Example: "My user Account"
REM *********************************************************************

echo Running as user: %USERNAME%
echo.
echo PLEASE NOTE: 
echo              This MUST be run as Administrator!!!
echo              You must enclose any comment in double Quotes
echo              Example: "My user Account"
echo.

set USERNAME=%1
set PASSWORD=%2
set COMMENT=%3

REM Check if we got ALL parameters
if "!USERNAME!"=="" goto usage
if "!PASSWORD!"=="" goto usage
if "!COMMENT!"=="" goto usage
if "!USERNAME!"=="" if "!PASSWORD!"=="" (
  goto usage
)


if NOT "!COMMENT!"=="" (
  echo Adding user %USERNAME% with comment %COMMENT%
  Net user /add %USERNAME% %PASSWORD% /fullname:"%USERNAME%" /comment:%COMMENT%
) else (
  echo Adding user %USERNAME%
  Net user /add %USERNAME% %PASSWORD% /fullname:"%USERNAME%"
)

Net user %USERNAME% /Expires:Never


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: addlocaluser.bat arg1 arg2 arg3
echo arg1 = Username for local account (Example: user1)
echo arg2 = Password for local account (Example: mysecretpassword)
echo arg3 (Optional) = Comment for local account  (Example: "This is my new user")
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%