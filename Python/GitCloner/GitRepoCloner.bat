
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: GitRepoCloner.bat
REM Author: Richard Knechtel
REM Date: 04/16/2016
REM Description: This script will allow you to clone or update (pull)
REM               Git Repos
REM
REM Example Call:
REM GitRepoCloner.bat clone "C:\Scripts\Python\SearchGit\sqlitedb\GitRepos.s3db" "D:\GitClonedRepos"
REM
REM ************************************************************************

@echo.
@echo Running as user: %USERNAME%
@echo.

REM Get parameters
@echo Parameters Passed = %1 %2 %3
@echo.

set GITCOMMAND=%1
set DB=%2
set CLONEDIR=%3

REM Check if we got ALL parameters
if "!GITCOMMAND!"=="" goto usage
if "!DB!"=="" goto usage
if "!CLONEDIR!"=="" goto usage
if "!GITCOMMAND!"=="" if "!DB!"=="" if "!CLONEDIR!"=="" (
  goto usage
)


REM set Script Path
set SCRIPTPATH=C:\Scripts\Python\GitCloner

@echo 

@echo *********************************************************************************************************
@echo Cloning/Update (pull) Git Repos
@echo *********************************************************************************************************

call python %SCRIPTPATH%\GitRepoCloner.py %GITCOMMAND% %DB% %CLONEDIR%

REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: GitRepoCloner.bat arg1 arg2 arg3
echo arg1 = Git command (Options: clone pull)
echo arg2 = SQLite Database (Example: D:\DB\MYDB.s3db)
echo arg3 = Repo Clone Directory (Example: D:\RepoClones)

goto getoutofhere

:getoutofhere
Exit /B

REM END
