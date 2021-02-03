@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: CheckPermissions.bat
REM Author: Richard Knechtel
REM Date: 01/27/2016
REM Description: This script will check if you have Administration 
REM              privliedges
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM Explanation
REM 
REM NET SESSION is a standard command used to "manage server computer connections. Used without parameters, [it] displays information about all sessions with the local computer."
REM https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-xp/bb490711(v=technet.10)
REM 
REM So, here's the basic process of my given implementation:
REM 
REM     @echo off
REM         Disable displaying of commands
REM     goto check_Permissions
REM         Jump to the :check_Permissions code block
REM     net session >nul 2>&1
REM         Run command
REM         Hide visual output of command by
REM             Redirecting the standard output (numeric handle 1 / STDOUT) stream to nul
REM             Redirecting the standard error output stream (numeric handle 2 / STDERR) to the same destination as numeric handle 1
REM     if %errorLevel% == 0
REM         If the value of the exit code (%errorLevel%) is 0 then this means that no errors have occurred and, therefore, the immediate previous command ran successfully
REM     else
REM         If the value of the exit code (%errorLevel%) is not 0 then this means that errors have occurred and, therefore, the immediate previous command ran unsuccessfully
REM     The code between the respective parenthesis will be executed depending on which criteria is met
REM ************************************************************************

goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
    ) else (
        echo Failure: Current permissions inadequate.
    )

    pause >nul
