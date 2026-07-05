@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

@REM *********************************************************************
@REM Script: DeploymentScheduler.bat
@REM Author: Richard Knechtel
@REM Date: 03/17/2026
@REM Description: This simulate a dice roll and the number shown will be
@REM              the month or day the prod deploy is done.
@REM
@REM Usage: DeploymentScheduler.bat [month|day]
@REM
@REM LICENSE: 
@REM This script is in the public domain, free from copyrights or restrictions.
@REM
@REM *********************************************************************

:: ============================================================
::  DeploymentScheduler.bat
::  Usage: DeploymentScheduler.bat [month|day]
:: ============================================================

:: --- Validate parameter ---
IF "%~1"=="" (
    ECHO [ERROR] No parameter provided.
    ECHO Usage: %~nx0 [month^|day]
    EXIT /B 1
)

SET "PARAM=%~1"

IF /I NOT "%PARAM%"=="month" IF /I NOT "%PARAM%"=="day" (
    ECHO [ERROR] Invalid parameter: "%PARAM%"
    ECHO Parameter must be either "month" or "day".
    EXIT /B 1
)

:: ============================================================
::  MONTH  --  Roll two dice to produce a value from 1 to 12
::             Die 1: 1-2  (selects first or second half-year)
::             Die 2: 1-6  (selects month within that half)
::             Formula: ((Die1 - 1) * 6) + Die2  =  1..12
:: ============================================================
IF /I "%PARAM%"=="month" (

    SET /A "DIE1=(%RANDOM% %% 2) + 1"
    SET /A "DIE2=(%RANDOM% %% 6) + 1"
    SET /A "ROLL=((DIE1 - 1) * 6) + DIE2"

    ECHO.
    ECHO  Rolling two dice...
    ECHO.
    ECHO  +-------+   +-------+
    ECHO  ^|       ^|   ^|       ^|
    ECHO  ^|  [!DIE1!]  ^|   ^|  [!DIE2!]  ^|
    ECHO  ^|       ^|   ^|       ^|
    ECHO  +-------+   +-------+
    ECHO   Die 1         Die 2
    ECHO.
    ECHO   Total : !ROLL!
    ECHO.

    IF !ROLL!==1  SET "RESULT=January"
    IF !ROLL!==2  SET "RESULT=February"
    IF !ROLL!==3  SET "RESULT=March"
    IF !ROLL!==4  SET "RESULT=April"
    IF !ROLL!==5  SET "RESULT=May"
    IF !ROLL!==6  SET "RESULT=June"
    IF !ROLL!==7  SET "RESULT=July"
    IF !ROLL!==8  SET "RESULT=August"
    IF !ROLL!==9  SET "RESULT=September"
    IF !ROLL!==10 SET "RESULT=October"
    IF !ROLL!==11 SET "RESULT=November"
    IF !ROLL!==12 SET "RESULT=December"

    ECHO  The production deployment will be done in !RESULT!.
    ECHO.
    GOTO :EOF
)

:: ============================================================
::  DAY  --  Roll one die to produce a value from 1 to 6
:: ============================================================
IF /I "%PARAM%"=="day" (

    SET /A "ROLL=(%RANDOM% %% 6) + 1"

    ECHO.
    ECHO  Rolling one die...
    ECHO.
    ECHO  +-------+
    ECHO  ^|       ^|
    ECHO  ^|  [!ROLL!]  ^|
    ECHO  ^|       ^|
    ECHO  +-------+
    ECHO.

    IF !ROLL!==1 SET "RESULT=Monday"
    IF !ROLL!==2 SET "RESULT=Tuesday"
    IF !ROLL!==3 SET "RESULT=Wednesday"
    IF !ROLL!==4 SET "RESULT=Thursday"
    IF !ROLL!==5 SET "RESULT=Friday"
    IF !ROLL!==6 SET "RESULT=Saturday"

    ECHO  The production deployment will be done on !RESULT!.
    ECHO.
    GOTO :EOF
)

ENDLOCAL