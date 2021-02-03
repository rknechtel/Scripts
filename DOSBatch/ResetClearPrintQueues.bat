
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: ResetClearPrintQueues.bat
REM Author: Richard Knechtel
REM Date: 02/03/2021
REM Description: This script will allow you to clear print spooler queue
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM 
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set SERVERNAME=%1
set COMMENT=%2

REM Set default Error Number
set ERRORNUMBER=0

echo Stopping Print Spooler
net stop spooler

echo Clearing Print Spooler queue
del /F /Q %systemroot%\System32\spool\PRINTERS\*

echo Starting Print Spooler
net start spooler


REM Lets get out of here!
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%