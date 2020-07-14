@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: GetOpenAPIJson.bat
REM Author: Richard Knechtel
REM Date: 04/16/2016
REM Description: This script will allow you get the JSON from an OpenAPI
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Example Call:
REM GetOpenAPIJson.bat dev My-Service
REM
REM ************************************************************************

@echo.
@echo Running as user: %USERNAME%
@echo.

REM Get parameters
@echo Parameters Passed = %1 %2
@echo.

REM set ENVIRONMENT=%1
set APINAME=%1
set JSONURL=%2

REM Check if we got ALL parameters
if "!APINAME!"=="" goto usage
if "!JSONURL!"=="" goto usage
if "!APINAME!"=="" if "!JSONURL!"=="" (
   goto usage
)

REM set Script Path
REM set SCRIPTPATH=C:\Scripts\Python\GetOpenAPIJson
set SCRIPTPATH=C:\Users\rknechtel\Data\GitHubRepos\Scripts\Python\GetOpenAPIJson

@echo

@echo
*********************************************************************************************************
@echo Starting GetOpenAPIJson
@echo
*********************************************************************************************************

call python %SCRIPTPATH%\GetOpenAPIJson.py %APINAME% %JSONURL%

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: GetOpenAPIJson.bat arg1 arg2
echo arg1 = API Name (Example: My-Service)
echo arg2 = JSON URL or Full File Path 
echo        (Example: https://devapache.my.com/my-service/v2/api-docs?group=public-api)
echo        (Example: C;\Temp\myfile.json)

goto getoutofhere

:getoutofhere
Exit /B

REM END
