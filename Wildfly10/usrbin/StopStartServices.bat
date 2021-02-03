
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: StopStartServices.bat
REM Author: Richard Knechtel
REM Date: 06/26/2017
REM Description: This script will allow you to 
REM              stop/start the Wildfly/Apache Windows Service(s)
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Parameters:
REM            Command (Example: stop/start)
REM            Number of AppSrv instances to stop/start (Example: 5)
REM 
REM Notes:
REM        Must be run as Administrator!!
REM        Stop Order: Apache needs to be stopped first and then the 
REM                    Wildfly instances (So mod_jk doesn't freak out)
REM        Start Order: Wildfly instances need to start first
REM                     then start Apache (so mod_jk can see Wildfly)
REM ************************************************************************

echo Running as user: %USERNAME%

REM Get parameters
set COMMAND=%1
set APPSRVINSTANCES=%2

REM Set default Error Number
set ERRORNUMBER=0



REM Check if we got ALL parameters
if "!COMMAND!"=="" goto usage
if "!APPSRVINSTANCES!"=="" goto usage
if "!COMMAND!"=="" if "!APPSRVINSTANCES!"=="" (
  goto usage
)

REM How many AppSrv instances do we need to stop
set /A NUMAPPSRVINSTANCES=%APPSRVINSTANCES%

REM set a default app server instance
set WILDFLYSERVICE=AppSrv0%NUMAPPSRVINSTANCES%


REM ******************************************************
REM Validate User Input
REM ******************************************************
@echo.
@echo Validating user input.....
@echo.

REM Validate the user enter a valid command
@echo Validating the user entered a valid command
REM Note:
REM Initialize a test variable containing a delimited list of acceptable values, 
REM and then use search and replace to test if your variable is within the list. 
REM This is very fast and uses minimal code for an arbitrarily long list. 
REM It does require delayed expansion (or else use the CALL %%VAR%% trick). 
REM Also the test is CASE INSENSITIVE.
REM The below can fail if VAR contains =, so the test is not fool-proof.
set "TESTCMD=;start;stop;"
if "!TESTCMD:;%COMMAND%;=!" neq "!TESTCMD!" ( 
  @echo valid command passed
) else ( 
  @echo You did not enter a valid command, commmand must be start or stop, you entered %COMMAND%.
  REM Lets get out of here!
  goto getoutofhere
)


REM Make sure user entered a number
@echo Validating the user entered a numeric number for AppSrv Instances
echo %APPSRVINSTANCES%|findstr /r /c:"^[0-9][0-9]*$" >nul
if %ERRORLEVEL% GTR 0 (
  REM User didn't give us a number!
  @echo Paramerter 2 MUST be a numeric - Exiting.
  REM Lets get out of here!
  goto getoutofhere
) else (
  @echo Numeric values was enetered
)


REM Make sure number of AppSrv instances is greater than 0 (Zero)
REM Note: Must use a ^ to escape parenthesis!!! (Stupid Microsoft!)
if %NUMAPPSRVINSTANCES% LEQ 0 (
  @echo The Number of AppSrv Instances must be greater than 0 (Zero^) - try again.
  REM Lets get out of here!
  goto getoutofhere
) else (
  echo Number of AppSrv Instances is greater than 0 (Zero^)
)

	
@echo Processing the command given: %COMMAND%
REM ******************************************************
REM Process the Command:
REM ******************************************************
if /I "%COMMAND%" == "start"     goto cmdStart
if /I "%COMMAND%" == "stop"      goto cmdStop


REM ******************************************************
REM Stop Windows Services:
REM ******************************************************
:cmdStop

REM ******************************************************
REM 1) Stop Apache
REM ******************************************************
@echo.
@echo Stopping Apache2.4.
@echo.

@echo Verifying Apache2.4 is running.
FOR /F "tokens=3" %%A IN ('sc queryex Apache2.4 ^| findstr PID') DO (SET pid=%%A)
IF "!pid!" GTR "0" (
  @echo Apache2.4 is running - Stopping Apache2.4.
  net stop Apache2.4

  @echo Verifying Apache2.4 is stopped.
  FOR /F "tokens=3" %%A IN ('sc queryex Apache2.4 ^| findstr PID') DO (SET pid=%%A)
  IF "!pid!"=="0" (
    @echo Apache2.4 is stopped.
  )
) ELSE (
  @echo Apache2.4 is not running - skipping......
)


REM ******************************************************
REM 2a) Stop Wildfly 8.2.1-Final AppSrv Instances
REM ******************************************************
@echo.
@echo Stopping Wildfly 8.2.1-Final AppSrv Instances
@echo.

@echo Attempting to Stop Wildfly 8.2.1-Final AppSrv Instances 1 - %NUMAPPSRVINSTANCES% ......
FOR /L %%A IN (1,1,%NUMAPPSRVINSTANCES%) DO (

  @echo Verifying Wildfly 8.2.1-Final AppSrv0%%A exists and is running.
  REM Check which Windows Service name is used:
  sc query state= all | findstr /C:"SERVICE_NAME: WF8APPSRV0%%A" 
  if %ERRORLEVEL% EQU 0 (
    set WILDFLYSERVICE=WF8APPSRV0%%A
  ) else (
    sc query state= all | findstr /C:"SERVICE_NAME: APPSRV0%%A" 
    if %ERRORLEVEL% EQU 0 (
      set WILDFLYSERVICE=APPSRV0%%A
    )
  )
  
  REM @echo WILDFLYSERVICE=!WILDFLYSERVICE!
  
  FOR /F "tokens=3" %%B IN ('sc queryex !WILDFLYSERVICE! ^| findstr PID') DO (SET pid=%%B)
  IF "!pid!" GTR "0" (
    @echo AppSrv0%%A is running - Stopping Wildfly 8.2.1-Final AppSrv0%%A.
    net stop !WILDFLYSERVICE!

    @echo Verifying Wildfly 8.2.1-Final AppSrv0%%A is stopped.
    FOR /F "tokens=3" %%C IN ('sc queryex !WILDFLYSERVICE! ^| findstr PID') DO (SET pid=%%C)
    IF "!pid!"=="0" (
      @echo Wildfly 8.2.1-Final AppSrv0%%A is stopped.
    )
  ) ELSE (
    @echo Wildfly 8.2.1-Final AppSrv0%%A is not running - skipping......
  )
)
 
 
REM ****************************************************** 
REM 2b) Stop Wildfly 10.1.0.Final AppSrv Instances
REM ******************************************************
@echo.
@echo Stopping Wildfly 10.1.0.Final AppSrv Instances
@echo.

@echo Attempting to Stop Wildfly 10.1.0.Final AppSrv Instances 1 - %NUMAPPSRVINSTANCES% ......
FOR /L %%A IN (1,1,%NUMAPPSRVINSTANCES%) DO (

  @echo Verifying Wildfly 10.1.0.Final AppSrv0%%A is running.
  REM Check which Windows Service name is used:
  sc query state= all | findstr /C:"SERVICE_NAME: WF10APPSRV0%%A" 
  if %ERRORLEVEL% EQU 0 (
    set WILDFLYSERVICE=WF10APPSRV0%%A
  ) else (
    sc query state= all | findstr /C:"SERVICE_NAME: APPSRV0%%A" 
    if %ERRORLEVEL% EQU 0 (
      set WILDFLYSERVICE=APPSRV0%%A
    )
  )
  
  REM @echo WILDFLYSERVICE=!WILDFLYSERVICE!
  
  FOR /F "tokens=3" %%B IN ('sc queryex WF10APPSRV0%%A ^| findstr PID') DO (SET pid=%%B)
  IF "!pid!" GTR "0" (
    @echo AppSrv0%%A is running - Stopping Wildfly 10.1.0.Final AppSrv0%%A.
    net stop !WILDFLYSERVICE!

    @echo Verifying Wildfly 10.1.0.Final AppSrv0%%A is stopped.
    FOR /F "tokens=3" %%C IN ('sc queryex !WILDFLYSERVICE! ^| findstr PID') DO (SET pid=%%C)
    IF "!pid!"=="0" (
      @echo Wildfly 10.1.0.Final AppSrv0%%A is stopped.
    )
  ) ELSE (
    @echo Wildfly 10.1.0.Final AppSrv0%%A is not running - skipping......
  )
)


REM Lets get out of here!
goto getoutofhere


REM Start Windows Services:
:cmdStart

REM ******************************************************
REM 1a) Start Wildfly 8.2.1-Final AppSrv Instances
REM ******************************************************
@echo.
@echo Starting Wildfly 8.2.1-Final AppSrv Instances
@echo.

@echo Attempting to Start Wildfly 8.2.1-Final AppSrv Instances 1 - %NUMAPPSRVINSTANCES% ......
FOR /L %%A IN (1,1,%NUMAPPSRVINSTANCES%) DO (

  @echo Verifying Wildfly 8.2.1-Final AppSrv0%%A is not running.
  REM Check which Windows Service name is used:
  sc query state= all | findstr /C:"SERVICE_NAME: WF8APPSRV0%%A" 
  if %ERRORLEVEL% EQU 0 (
    set WILDFLYSERVICE=WF8APPSRV0%%A
  ) else (
    sc query state= all | findstr /C:"SERVICE_NAME: APPSRV0%%A" 
    if %ERRORLEVEL% EQU 0 (
      set WILDFLYSERVICE=APPSRV0%%A
    )
  )
  
  REm @echo WILDFLYSERVICE=!WILDFLYSERVICE!
  
  FOR /F "tokens=3" %%B IN ('sc queryex !WILDFLYSERVICE! ^| findstr PID') DO (SET pid=%%B)
  IF "!pid!"=="0" (
    @echo AppSrv0%%A is not running - Starting Wildfly 8.2.1-Final AppSrv0%%A.
    net start !WILDFLYSERVICE!

    @echo Verifying Wildfly 8.2.1-Final AppSrv0%%A is running.
    FOR /F "tokens=3" %%C IN ('sc queryex !WILDFLYSERVICE! ^| findstr PID') DO (SET pid=%%C)
    IF "!pid!" NEQ "0" (
      @echo Wildfly 8.2.1-Final AppSrv0%%A is running.
    )
  ) ELSE (
    @echo Wildfly 8.2.1-Final AppSrv0%%A is already running - skipping......
  )
)


REM ******************************************************
REM 1b) Start Wildfly 10.1.0.Final AppSrv Instances
REM ******************************************************
@echo.
@echo Starting Wildfly 10.1.0.Final AppSrv Instances
@echo.

@echo Attempting to Start Wildfly 10.1.0.Final AppSrv Instances...... 
FOR /L %%A IN (1,1,%NUMAPPSRVINSTANCES%) DO (
  @echo Verifying Wildfly 10.1.0.Final AppSrv0%%A is not running.
  REM Check which Windows Service name is used:
  sc query state= all | findstr /C:"SERVICE_NAME: WF10APPSRV0%%A" 
  if %ERRORLEVEL% EQU 0 (
    set WILDFLYSERVICE=WF10APPSRV0%%A
  ) else (
    sc query state= all | findstr /C:"SERVICE_NAME: APPSRV0%%A" 
    if %ERRORLEVEL% EQU 0 (
      set WILDFLYSERVICE=APPSRV0%%A
    )
  )
  
  REM @echo WILDFLYSERVICE=!WILDFLYSERVICE!
  
  FOR /F "tokens=3" %%B IN ('sc queryex !WILDFLYSERVICE! ^| findstr PID') DO (SET pid=%%B)
  IF "!pid!"=="0" (
    @echo AppSrv0%%A is not running - Starting Wildfly 10.1.0.Final AppSrv0%%A.
    net start !WILDFLYSERVICE!

    @echo Verifying Wildfly 10.1.0.Final AppSrv0%%A is running.
    FOR /F "tokens=3" %%C IN ('sc queryex!WILDFLYSERVICE! ^| findstr PID') DO (SET pid=%%C)
    IF "!pid!" NEQ "0" (
      @echo Wildfly 10.1.0.Final AppSrv0%%A is running.
    )
  ) ELSE (
    @echo Wildfly 10.1.0.Final AppSrv0%%A is already running - skipping......
  )
)


REM ******************************************************
REM 2) Start Apache
REM ******************************************************
@echo.
@echo Starting Apache2.4.
@echo.

@echo Verifying Apache2.4 is not running.
FOR /F "tokens=3" %%A IN ('sc queryex Apache2.4 ^| findstr PID') DO (SET pid=%%A)
IF "!pid!"=="0" (
  @echo Apache2.4 is not running - Starting Apache2.4.
  net start Apache2.4

  @echo Verifying Apache2.4 is running.
  FOR /F "tokens=3" %%A IN ('sc queryex Apache2.4 ^| findstr PID') DO (SET pid=%%A)
  IF "!pid!" NEQ "0" (
    @echo Apache2.4 is running.
  )
) ELSE (
  @echo Apache2.4 is already running - skipping......
)


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: StopStartApp.bat arg1 arg2
echo arg1 = Command (start / stop)
echo arg2 = Number of AppSrv instances to stop/start (Example: 5)
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
