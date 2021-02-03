@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: ConvertSVN2Git.bat
REM Author: Richard Knechtel
REM Date: 09/28/2017
REM Description: This script will Convert and SVN project into a GIT one. 
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Note: See the comments in ConvertSVN2Git.ps1
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
set SVNPATH=%1
set TARGETPATH=%2
set AUTHORSFILE=%3

echo.
echo Parameters Passed: 
echo SvnPath: %SVNPATH% 
echo TargetPath: %TARGETPATH% 
echo AuthorsFile: %AUTHORSFILE%
echo.

REM Check if we got ALL parameters
if "!SVNPATH!"=="" goto usage
if "!TARGETPATH!"=="" goto usage
if "!AUTHORSFILE!"=="" goto usage
if "!SVNPATH!"=="" if "!TARGETPATH!"=="" if "!AUTHORSFILE!"=="" (
   goto usage
)

REM set Script Path (change to wherever you have the script)
set SCRIPTPATH=D:\work\gitconvert

REM Call Powershell: ConvertSVN2Git.ps1 -SvnPath %SVNPATH% -TargetPath %TARGETPATH% -AuthorsFile %AUTHORSFILE%
@echo ConvertSVN2Git running - Script Path = %SCRIPTPATH%
echo Calling: "PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\ConvertSVN2Git.ps1 -SvnPath %SVNPATH% -TargetPath %TARGETPATH% -AuthorsFile %AUTHORSFILE%"
PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\ConvertSVN2Git.ps1 -SvnPath %SVNPATH% -TargetPath %TARGETPATH% -AuthorsFile %AUTHORSFILE%


REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: ConvertSVN2Git.bat arg1 arg2 arg3
echo arg1 = Svn URL/Path (Example: https://svn.mydomain.com/svn/MyRepo/MyApplication) 
echo arg2 = Target Path for Git Project (Example: D:\Work\gitconvert\MyApplication) 
echo arg3 = Path to Authors File (Example: D:\Work\gitconvert\authors.txt)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORNUMBER%