#!/bin/bash

##!/bin/sh

# ************************************************************************
# Script: ArchiveLogs.sh
# Author: Richard Knechtel
# Date: 02/12/2021
# Description: This script will allow you to
#              Archive Wildfly Log files 
#              and optionally purge old archives (by number of days)
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# Notes:
#   Must be run as Administrator!!
#   Because it needs admin authority for stopping/starting Windows services.
#   Example Call:
#   ArchiveLogs.sh AppSrv01
#   Or to Purge:
#   ArchiveLogs.sh AppSRv01 30
#
# ************************************************************************

echo
echo "******************************************"
echo "This script MUST be run as Administrator."
echo "******************************************"
echo
echo "Running as user: $USER"
echo

# Get parameters
echo "Parameters Passed = " $1 $2 $3
echo

APPSRV=$1
RESTARTINSTANCE=$2
PURGE=$3

# Check if we got ALL parameters
if [ $# -eq 0 ]  || [ -z "$APPSRV" ] || [ -z "$RESTARTINSTANCE" ] || [ -z "$PURGE" ] 
 then
  echo "[USAGE]: ArchiveLogs.sh arg1 arg2 arg3"
  echo "arg1 = AppSrv Instance (Example: AppSrv01)"
  echo "arg2 = Should AppSrv Instance be restarted (Example: no)"
  echo "arg3 = (Optional) = Days Older than to Purge (Example: 30)"
  echo                     "Note: This will purge any logs older than 30 days."
  exit 1
fi


# Get servers hostname for SERVER:
SERVER=$HOSTNAME
echo server=$SERVER

# Setup needed variables:
LOGDIR=$JBOSS_HOME/$APPSRV/log
ARCHIVELOGDIR=$LOGDIR/Archive
SERVICELOC=local

# set SERVICE variable - Convert AppSrv instance to upper case for Windows Service:
# To convert the AppSrv instance to upper case we are going to use a hack and abuse the tree commands error message - just 'cause we can!
upper=
str=$APPSRV
for /f "skip=2 delims=" %%I in ('tree "\%str%"') do if not defined upper set "upper=%%~I"
set "upper=%upper:~3%"
set SERVICE=WF10%upper%
echo service=%SERVICE%

# set Script Path
set SCRIPTPATH=D:\Scripts

echo 

echo *********************************************************************************************************
echo Starting Archive Process
echo *********************************************************************************************************

# 1) Stop AppSrv instance
if /I "!RESTARTINSTANCE!" EQU "yes" (
  echo Stopping %SERVICE% Windows Service
  echo PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "stop" %SERVICE% %SERVER% "local"
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "stop" %SERVICE% %SERVER% "local"
)


# Get the Current date as MM-dd-yyyy format and set Zip File Name
for /f %%a in ('powershell -Command "Get-Date -format MM-dd-yyyy"') do set mmddyyyy=%%a

set ZIPFILE=%mmddyyyy%-$APPSRV-Logs.zip
echo Zip File Name = %ZIPFILE%

# Steps 2) Zip up log files.
# echo calling %JBOSS_HOME%\usrbin\ArchiveLogs.ps1 %LOGDIR% %ARCHIVELOGDIR% %ZIPFILE%
# PowerShell -ExecutionPolicy Bypass -File %JBOSS_HOME%\usrbin\ArchiveLogs.ps1 $APPSRV %ZIPFILE%

# Jython Version:
# echo calling %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py %LOGDIR% %ZIPFILE%
# echo JYTHON_HOME = %JYTHON_HOME%
# call %JYTHON_HOME%\bin\jython %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py $APPSRV %ZIPFILE%

# Python Version:
echo calling %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py %LOGDIR% %ZIPFILE%
echo PYTHON_HOME = %PYTHON_HOME%
call %PYTHON_HOME%\python %JBOSS_HOME%\usrbin\Python\ArchiveLogs.py $APPSRV %ZIPFILE%

echo error level=%ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 (
  echo Archive Of Logs Failed.
  set ERRORNUMBER=1
  set ERRORMESSAGE=Archive Of Logs Failed.
) else (
  echo Archive Of Logs Succeeded.
  set ERRORNUMBER=0
  set ERRORMESSAGE=Archive Of Logs Succeeded.
)


# 5) Start AppSrv Instance Windows service.
if /I "!RESTARTINSTANCE!" EQU "yes" (
  echo Starting %SERVICE% Windows Service
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 "start" %SERVICE% %SERVER% "local"
)

# 6) Check to make sure Apps are in deployed state.
# WORK ON!

# OPTIONAL:
# 7) Delete Archived log files (more than 30 days old).
if NOT "!PURGE!"=="" (

  echo %PURGE%| findstr /r "^[1-9][0-9]*$">nul
  if %errorlevel% equ 0 (
    # PURGE contains a valid number - Do purge:
	echo Purging archived log files for $APPSRV that are older than %PURGE% days	
	PowerShell -Command "Get-ChildItem '%ARCHIVELOGDIR%' | Where {$_.lastwritetime -lt (Get-Date).AddDays(-%PURGE%)} | #ove-Item -Force -ErrorAction SilentlyContinue"
  )
  
)

echo "*********************************************************************************************************"
echo "Finished Archive Process"
echo "*********************************************************************************************************"

# Lets get out of here!
exit 0

# END
