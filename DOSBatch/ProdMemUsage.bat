
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: ProdMemUsage.bat
REM Author: Richard Knechtel
REM Date: 01/27/2016
REM Description: This script will get the Wildfly Instance memory usage
REM
REM Notes:
REM   Must be run as Administrator!!
REM
REM ************************************************************************

@echo.
@echo ******************************************
@echo This script MUST be run as Administrator.
@echo ******************************************
@echo.
@echo Running as user: %USERNAME%
@echo.

REM Set default Error Level
set ERRORLEVEL=0
set ERRORNUMBER=0
set ERRORMESSAGE=Success

CALL :check_Permissions

if %ERRORNUMBER% NEQ 0 (
  set ERRORNUMBER=1
  set ERRORMESSAGE=You need Administrative privileges to run this script!
  REM Lets get out of here!
  goto getoutofhere
) Else (
 set ERRORNUMBER=0
 set ERRORMESSAGE=Success
)

REM Get parameters
REM @echo Parameters Passed = %1 %2 %3
REM @echo.
REM set APPSRV=%1
REM set RESTARTINSTANCE=%2
REM set PURGE=%3

REM Check if we got ALL parameters
REM if "!APPSRV!"=="" goto usage
REM if "!RESTARTINSTANCE!"=="" goto usage
REM if "!APPSRV!"=="" if "!RESTARTINSTANCE!"=="" (
REM   goto usage
REM )


REM Get servers hostname for SERVER:
for /F "usebackq" %%i in (`hostname`) do set SERVER=%%~i
echo server=%SERVER%

REM Setup needed variables:
set OUTPUTDIR=C:\Temp
REM set Script Path
set SCRIPTPATH=C:\Scripts


@echo 

@echo *********************************************************************************************************
@echo Starting Capture of Wildfly Instance Processes
@echo *********************************************************************************************************

REM Get the Current date as MM-dd-yyyy format and set Zip File Name
for /f %%a in ('powershell -Command "Get-Date -format MM-dd-yyyy"') do set mmddyyyy=%%a
for /f %%b in ('powershell -Command "Get-Date -format HH:mm:ss"') do set hhmmss=%%b

REM Strip out all :'s
echo.%hhmmss%
set hhmmss=%hhmmss::=%
echo.%hhmmss%


set CSVFILE=ProdWildflyMemUsage-%mmddyyyy%_%hhmmss%.csv
@echo CSV File Name = %CSVFILE%

REM svc_ProdAppSrv* and svc_PIFSprod
REM tasklist /v /fi "Username eq svc_ProdAccounst" /fo csv >> %OUTPUTDIR%\%CSVFILE%
tasklist /v /fi "Username eq svc_P*" /fo csv >> %OUTPUTDIR%\%CSVFILE%


REM Search for "Mem Usage" repalce with "Mem Usage (KB)"
@echo Doing Relpace: powershell -Command "(gc %OUTPUTDIR%\%CSVFILE%) -replace 'Mem Usage', 'Mem Usage (KB)' | Out-File %OUTPUTDIR%\%CSVFILE%"
powershell -Command "(gc %OUTPUTDIR%\%CSVFILE%) -replace 'Mem Usage', 'Mem Usage (KB)' | Out-File %OUTPUTDIR%\%CSVFILE%"

REM search for all occurances of " K" replace with ""
@echo Doing Relpace: powershell -Command "(gc %OUTPUTDIR%\%CSVFILE%) -replace ' K', '' | Out-File %OUTPUTDIR%\%CSVFILE%"
powershell -Command "(gc %OUTPUTDIR%\%CSVFILE%) -replace ' K', '' | Out-File %OUTPUTDIR%\%CSVFILE%"


@echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  @echo Wildfly Memory Usage CSV file creation Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Wildfly Memory Usage CSV file creation Failed.
) else (
  @echo Wildfly Memory Usage CSV file creation Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Wildfly Memory Usage CSV file creation Succeeded.
)



@echo *********************************************************************************************************
@echo Finished Wildfly Memory Usage CSV file creation Process
@echo *********************************************************************************************************

REM Lets get out of here!
goto getoutofhere

:check_Permissions
    echo Administrative permissions required. Detecting permissions...
    echo.
	
	REM  Calling verify with no args just checks the verify flag,
    REM   we use this for its side effect of setting errorlevel to zero
    verify >nul

    REM  Attempt to read a particular system directory - the DIR
    REM   command will fail with a nonzero errorlevel if the directory is
    REM   unreadable by the current process.  The DACL on the
    REM   c:\windows\system32\config\systemprofile directory, by default,
    REM   only permits SYSTEM and Administrators.
    dir %windir%\system32\config\systemprofile >nul 2>nul

    REM  Use IF ERRORLEVEL or %errorlevel% to check the result
    if not errorlevel 1 (
        echo Success: Administrative permissions confirmed.
        set ERRORNUMBER=0
        set ERRORMESSAGE=Success: Administrative permissions confirmed
    )
    if errorlevel 1 (
       echo ######## ########  ########   #######  ########  
       echo ##       ##     ## ##     ## ##     ## ##     ## 
       echo ##       ##     ## ##     ## ##     ## ##     ## 
       echo ######   ########  ########  ##     ## ########  
       echo ##       ##   ##   ##   ##   ##     ## ##   ##   
       echo ##       ##    ##  ##    ##  ##     ## ##    ##  
       echo ######## ##     ## ##     ##  #######  ##     ## 
       echo.
       echo.
       echo ####### ERROR: ADMINISTRATOR PRIVILEGES REQUIRED #########
       echo This script must be run as administrator to work properly!  
       echo If you're seeing this after clicking on a start menu icon, 
       echo then right click on the shortcut and select
       echo "Run As Administrator".
       echo ##########################################################
       echo.
       set ERRORNUMBER=1
       set ERRORMESSAGE=You need Administrative privileges to run this script! 
    )
    EXIT /B %ERRORNUMBER%



REM :usage
REM set ERRORNUMBER=1
REM echo [USAGE]: ProdMemUsage.bat arg1 arg2 arg3
REM echo arg1 = arg 1 (Example: arg1)
REM echo arg2 = arg 2 Instance be restarted (Example: arg 2)
REM echo arg3 arg 2 (Example: arg 3)

goto getoutofhere

:getoutofhere
@echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORNUMBER% %ERRORMESSAGE%

REM END
