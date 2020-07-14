
@echo off
setlocal EnableDelayedExpansion
REM ************************************************************************
REM Script: setjbosshome.bat
REM Author: Richard Knechtel
REM Date: 04/22/2015
REM Description: This script will Set JBOSS_HOME
REM License: Copyleft
REM
REM ************************************************************************

set NEW_JBOSSHOME=%1
setX JBOSS_HOME %NEW_JBOSSHOME% /m