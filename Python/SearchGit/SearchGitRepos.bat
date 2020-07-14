@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: SearchGitRepos.bat
REM Author: Richard Knechtel
REM Date: 04/16/2016
REM Description: This script will allow you to Search across multiple
REM               Git Repos
REM
REM Example Call:
REM SearchGitRepos.bat MySearchString
REM
REM ************************************************************************

@echo.
@echo Running as user: %USERNAME%
@echo.

REM Get parameters
@echo Parameters Passed = %1
@echo.

set SEARCHTERM=%1

REM Check if we got ALL parameters
if "!SEARCHTERM!"=="" goto usage


REM set Script Path
set SCRIPTPATH=C:\Scripts\Python\SearchGit

@echo

@echo
*********************************************************************************************************
@echo Starting SearchGitRepos
@echo
*********************************************************************************************************

call python %SCRIPTPATH%\SearchGitRepos.py %SEARCHTERM%

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: SearchGitRepos.bat arg1
echo arg1 = Search Term (Example: MySearchTerm)

goto getoutofhere

:getoutofhere
Exit /B

REM END