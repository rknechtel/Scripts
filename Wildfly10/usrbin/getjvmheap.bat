@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: getjvmheap.bat
REM Author: Richard Knechtel
REM Date: 04/20/2015
REM Description: This script will report the JVM Heap.
REM
REM Notes:
REM       1) Need to have and AppSrv instance Alias configured in:
REM          %JBOSS_HOME%\bin\jboss-cli.xml
REM          Under <controllers>
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set APPSRV=%1

REM Eliminate the "Press any key to continue"
set NOPAUSE=true

REM Check if we got ALL parameters
if "!APPSRV!"=="" goto usage

REM 1048576 = 1 MB
for /f "tokens=3" %%i in ('"%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=/core-service=platform-mbean/type=memory:read-attribute(name=heap-memory-usage)" ^| findstr used') do set "USED=%%i"
set heapused=!USED:~0,-2!
set /A "heapusedmb=%heapused% /1048576"

for /f "tokens=3" %%i in ('"%JBOSS_HOME%\bin\jboss-cli.bat --connect --controller=%APPSRV% --command=/core-service=platform-mbean/type=memory:read-attribute(name=heap-memory-usage)" ^| findstr max') do set "MAX=%%i"
set heapmax=!MAX:~0,-1!
set /A "heapmaxmb=%heapmax% /1048576"

set /A "freememory=%heapmax%-%heapused%"
set /A "freememorymb=%freememory% /1048576"


@echo on
@echo.
@echo --------------------------------------------
@echo Heap Max: %heapmaxmb% MB
@echo Heap Used: %heapusedmb% MB
@echo Free Heap: %freememorymb% MB
@echo --------------------------------------------
@echo.
@echo off


REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: getjvmheap.bat arg1
echo arg1 = AppSrv Instance Name (Example: AppSrv01) goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%