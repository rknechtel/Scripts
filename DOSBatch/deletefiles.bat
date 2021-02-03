
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script Name: deletefiles.bat
REM Author: Richard Knechtel
REM Date: 06/08/2016
REM Description: delete files older than a specific number of days.
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM Number of days older than to delete (Example 30)
REM Path to delete files older than from (Example D:\MyApp\Logs)
REM
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set NUMDAYS=%1
set PATHTODEL=%2

REM Check if we got ALL parameters
if "!NUMDAYS!"=="" goto usage
if "!PATHTODEL!"=="" goto usage
if "!NUMDAYS!"=="" if "!PATHTODEL!"=="" (
   goto usage
)


REM Note: 
REM You can change this to take in a path of where to delete the files from to make it even more generic.

REM Change to drive logs are on:
set DRIVETOGOTO=!PATHTODEL:~0,-1!
echo %DRIVETOGOTO%

%DRIVETOGOTO%

REM CD to the directory the logs are in:
cd %PATHTODEL%

REM Delete files older than NUMDAYS% days. 
echo Deleting files older than NUMDAYS% days.
FORFILES /p %PATHTODEL% /s /m *.* /D -%NUMDAYS%  /C "cmd /c DEL @path"


REM Delete files/directories older than NUMDAYS% days. 

REM Uncomment below if you want to delete files and directories
REM echo Deleting files/directories older than NUMDAYS% days.
REM FORFILES /S /D -%NUMDAYS% /C "cmd /c IF @isdir == TRUE RMDIR /S /Q @path"



REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: adduser.bat arg1 arg2
echo arg1 = Number of days older than to delete (Example: 30) 
echo arg2 = Path to delete files older than from (Example D:\MyApp\Logs)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
