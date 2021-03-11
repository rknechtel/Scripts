
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: SearchGitRepos.bat
REM Author: Richard Knechtel
REM Date: 04/16/2016
REM Description: This script will allow you to Search across multiple
REM               Git Repos
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Example Call:
REM SearchGitRepos.bat MySearchString C:\Temp\GitRepos
REM
REM ************************************************************************

@echo.
@echo Running as user: %USERNAME%
@echo.

REM Get parameters
@echo Parameters Passed = %1 %2
@echo.

set SEARCHTERM=%1
set SEARCHPATH=%2

REM Check if we got ALL parameters
if "!SEARCHTERM!"=="" goto usage
if "!SEARCHPATH!"=="" goto usage
if "!SEARCHTERM!"=="" if "!SEARCHPATH!"=="" (
   goto usage
)

REM set Script Path
set SCRIPTPATH=D:\Scripts\Python\SearchGit

@echo

@echo
*********************************************************************************************************
@echo Starting SearchGitRepos
@echo
*********************************************************************************************************

call python %SCRIPTPATH%\SearchGitRepos.py %SEARCHTERM% %SEARCHPATH%

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: SearchGitRepos.bat arg1 arg2
echo arg1 = Search Term (Example: MySearchTerm)
echo arg2 = Search Path (Example: D;\Temp\GitRepos)

goto getoutofhere

:getoutofhere
Exit /B

REM END