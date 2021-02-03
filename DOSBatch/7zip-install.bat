
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: 7zip-install.bat
REM Author: Richard Knechtel
REM Date: 02/22/2018
REM Description: This script will allow you to silently install 7-Zip
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM   Must be run as Administrator!!
REM   Because it needs admin authority for doing installs
REM
REM   Example Call:
REM   For Z-Zip exe installer:
REM   D:\Installs\7zip-install.bat D:\Installs 7z1801-x64.exe
REM
REM   For 7-Zip msi installer (Best Method):
REM   D:\Installs\7zip-install.bat D:\Installs 7z1801-x64.msi
REM
REM Installer downloads are available at:
REM http://www.7-zip.org/download.html
REM
REM ************************************************************************

echo.
echo ******************************************
echo This script MUST be run as Administrator.
echo ******************************************
echo.
echo Running as user: %USERNAME%
echo.

REM Get Parameters
set INSTALLERDIR=%1
set INSTALLER=%2

REM Check if we got ALL parameters
if "!INSTALLERDIR!"=="" goto usage
if "!INSTALLER!"=="" goto usage
if "!INSTALLERDIR!"=="" if "!INSTALLER!"=="" (
  goto usage
)

REM Get File extention of installer so we can determine which install method we need to do.
set INSTALLEREXT=%~x2
REM Set the Error Number to 0 (zero) - default is everything ran fine.
set ERRORNUMBER=0

REM Show parameters passed and file extention
echo parameters passed: %INSTALLERDIR% %INSTALLER%
echo installer ext: %INSTALLEREXT%


echo --------------------------------------------------------
echo .
echo .           Installing 7-Zip - Please Wait.
echo .
echo --------------------------------------------------------

REM ********************************************
REM Silent install 7-Zip for 32-bit or 64-bit
REM ********************************************

REM Install for .exe installers
if /I "!INSTALLEREXT!" EQU ".exe" (
  start %INSTALLERDIR%\%INSTALLER% /S
  
  if %ERRORLEVEL% NEQ 0 (
    @echo Install of 7-Zip Failed.
	set ERRORNUMBER=1
  ) else (
    @echo Install of 7-Zip Succedded.
	set ERRORNUMBER=0
  )

)


REM Install for .msi installers
if /I "!INSTALLEREXT!" EQU ".msi" (
  msiexec.exe /i "%INSTALLERDIR%\%INSTALLER%" INSTALLDIR="D:\Apps\7-Zip" /qn /norestart
  
  if %ERRORLEVEL% NEQ 0 (
    @echo Install of 7-Zip Failed.
	set ERRORNUMBER=1
  ) else (
    @echo Install of 7-Zip Succedded.
	set ERRORNUMBER=0
  )  
)


@echo *********************************************************************************************************
@echo Finished Installing 7-Zip
@echo *********************************************************************************************************


REM Lets get out of here!
goto getoutofhere

REM Script Usage
:usage
set ERRORNUMBER=1
echo [USAGE]: 7zip-install.bat arg1 arg2
echo arg1 = Installer Directory (Example: C:\installs)
echo arg2 = 7-Zip Installer (Example: 7z1801-x64.msi)

goto getoutofhere

:getoutofhere
REM If ERRORNUMBER = 0 - the install Succedded
REM If ERRORNUMBER = 1 - the install Failed
Exit /B %ERRORNUMBER% %ERRORMESSAGE%

REM END
