
REM ************************************************************************
REM Function: check_Permissions
REM Author: Richard Knechtel
REM Date: 10/18/2018
REM Description: This function will allow you to check if run as admin
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Example Usage:
REM
REM Set default Error stuff
REM set ERRORNUMBER=0
REM set ERRORMESSAGE=Success
REM
REM @echo off
REM CALL :check_Permissions
REM
REM if %ERRORNUMBER% NEQ 0 (
REM   set ERRORNUMBER=1
REM   set ERRORMESSAGE=You need Administrative privileges  to run this script!
REM   REM Lets get out of here!
REM   goto getoutofhere
REM ) Else (
REM  set ERRORNUMBER=0
REM  set ERRORMESSAGE=Success
REM )
REM
REM :getoutofhere
REM @echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
REM Exit /B %ERRORNUMBER% %ERRORMESSAGE%
REM
REM
REM ************************************************************************

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
       set ERRORMESSAGE=You need Administrative privledges to run this script! 
    )
    EXIT /B %ERRORNUMBER%