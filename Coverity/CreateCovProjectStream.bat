
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: CreateCovProjectStream.bat
REM Author: Richard Knechtel
REM Date: 04/05/2015
REM Description: This script will let you create a Coverity Project 
REM              and Stream.
REM 
REM Notes:
REM   1) User running this requires the following roles in Coverity:
REM      Project Admin, Stream Admin
REM 
REM ************************************************************************

@echo.
@echo Running as user: %USERNAME%
@echo.


REM Get parameters
@echo Parameters Passed = %1 %2 ************** %4
set PROJECTNAME=%1
set USER=%2
set THEPASS=%3
set STREAMNAME=%4

REM Check if we got ALL parameters
if "!PROJECTNAME!"=="" goto usage
if "!USER!"=="" goto usage
if "!THEPASS!"=="" goto usage
if "!PROJECTNAME!"=="" if "!USER!"=="" if "!THEPASS!"=="" (
  goto usage
)


REM Set default Error Number and Message
set ERRORNUMBER=0
set ERRORMESSAGE=Creating Project and Stream in Coverity Successful

REM Set Coverity URL
set COVERITYURL=https://MYSERVER.DOMAIN.com:8443
set COVERITYHOST=MYSERVER.DOMAIN.com

REM ****************************************************************************
REM Create Project and Stream in Coverity
REM ****************************************************************************

if "!STREAMNAME!"=="" set STREAMNAME=%PROJECTNAME%
REM @echo PROJECTNAME = %PROJECTNAME%
REM @echo STREAMNAME = %STREAMNAME%

REM set COVERITY_HOME=S:\CovStatAnalysis
REM set COVERITY_HOME=D:\opt\Coverity\CovStatAnalysis

if "!COVERITY_HOME!"=="" (
  REM This would be the path to your Coverity Analysis Tools install. 
  REM It's best to map a drive to your Coverity install directory on the server.
  REM Make sure On Coverity Server Share is setup:
  REM New-SmbShare –Name Coverity –Path "D:\Program Files\Coverity\"
  set COVERITY_HOME=S:\CovStatAnalysis
) 

REM Check if Project is already in Coverity:
for /f %%i in ('"cov-manage-im --host %COVERITYHOST% --port 8080 --user %USER% --password %THEPASS% --mode projects --show --name %PROJECTNAME%" ^| findstr %PROJECTNAME%') do set "EXIST=%%i"
@echo EXIST = %EXIST%

if "!EXIST!"=="" (
  @echo on
  echo Project %PROJECTNAME% is not in Coverity, Adding it.

  REM Step 1) Create Project in Coverity
  @echo.
  @echo Creating Project in Coverity
  @echo.
  cov-manage-im --mode projects --add --set name:"%PROJECTNAME%" --set desc:"%PROJECTNAME%" --url %COVERITYURL% --user %USER% --password %THEPASS% --on-new-cert trust

  REM RSK 03/20/2020: Commenting out - project gets cretaed - false error reported
  REM @echo error level=%ERRORLEVEL%
  REM if %ERRORLEVEL% NEQ 0 (
  REM   @echo Creating Project in Coverity Failed.
  REM   set ERRORNUMBER=1
  REM   set ERRORMESSAGE=Creating Project in Coverity Failed.
  REM )


  REM Step 2) Create Stream in Coverity
  @echo.
  @echo Creating Stream in Coverity
  @echo.
  cov-manage-im --mode streams --add --set name:%STREAMNAME% --set desc:"%STREAMNAME%" --url %COVERITYURL% --user %USER% --password %THEPASS% --on-new-cert trust

  @echo error level=%ERRORLEVEL%
  if %ERRORLEVEL% NEQ 0 (
    @echo %Creating Stream in Coverity Failed.
    set ERRORNUMBER=1
    set ERRORMESSAGE=Creating Stream in Coverity Failed.
  )


  REM Step 3) Put Stream into Project in Coverity
  @echo.
  @echo Putting Stream into Project in Coverity
  @echo.
  cov-manage-im --mode projects --update --name "%PROJECTNAME%" --insert stream:%STREAMNAME% --url %COVERITYURL% --user %USER% --password %THEPASS% --on-new-cert trust

  @echo error level=%ERRORLEVEL%
  if %ERRORLEVEL% NEQ 0 (
    @echo Putting Stream into Project in Coverity Failed.
    set ERRORNUMBER=1
    set ERRORMESSAGE=Putting Stream into Project in Coverity Failed.
  )

  REM Step 3) Set Stream to do Automatic Owner Assignment based on SCM
  REM Ref: https://community.synopsys.com/s/article/SCM-Integration-Defect-Assignment
  @echo.
  @echo Setting Stream to do Automatic Owner Assignment based on SCM
  @echo.
  cov-manage-im --host %COVERITYHOST% --user %USER% --password %THEPASS% --mode streams --update --stream %STREAMNAME% --set ownerAssignmentOption:scm

  @echo error level=%ERRORLEVEL%
  if %ERRORLEVEL% NEQ 0 (
    @echo Setting Stream to do Automatic Owner Assignment based on SCM Failed.
    set ERRORNUMBER=1
    set ERRORMESSAGE=Setting Stream to do Automatic Owner Assignment based on SCM Failed.
  )

  @echo off

) else (
  @echo on
  echo Project %PROJECTNAME% is already in Coveirty - exiting.
  set ERRORNUMBER=1
  @echo off
) 

REM Lets get out of here!
goto getoutofhere



REM ****************************************************************************
REM Usage
REM ****************************************************************************
:usage
set ERRORLEVEL=1
echo [USAGE]: CreateCovProjectStream.bat arg1 arg2 arg3 arg4
echo arg1 = Project Name (Example: MyApplication)
echo arg2 = User (Example: MyUserId)
echo arg3 = Users Password (Example: MyP@$$W0rd)
echo arg4 = Stream Name (Example: MyApplication) (Optional - if not passed will use Project Name)
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
@echo ERRORNUMBER = %ERRORNUMBER%  -- ERRORMESSAGE = %ERRORMESSAGE%
Exit /B %ERRORLEVEL%
