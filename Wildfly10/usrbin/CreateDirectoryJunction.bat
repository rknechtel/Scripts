@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: CreateDirectoryJunction.bat
REM Author: Richard Knechtel
REM Date: 05/18/2017
REM Description: This will create the Wildfly Directory Junction
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM       This MUST be run as Administrator!!!
REM
REM *********************************************************************

echo Running as user: %USERNAME%
echo.
echo PLEASE NOTE: 
echo              This MUST be run as Administrator!!!
echo.


REM Create Wildfly Directory Junction
Echo Creating Wildfly Directory Junction
mklink /D /j D:\opt\Wildfly D:\opt\wildfly-10.1.0.Final

REM Enabling remote to remote and remote to local symbolic links
echo Enabling remote to remote and remote to local symbolic links
fsutil behavior set SymlinkEvaluation R2R:1 R2L:1

REM Verify symlinks enabled - should see "enabled" for all
echo Verifying symlinks enabled - should see "enabled" for all
fsutil behavior query SymlinkEvaluation

REM Set permissions on
REM This will set the other Env Vars in a new command prompt and exit it.
echo setting FullControl permissions for D:\opt\Wildfly for DOMIAN\SERVICEACCOUNT
call SetDOptWildflyPermisisons.bat


REM Note: if you need to rmeove Direcotry junction:
REM Try 1st: rmdir D:\opt\Wildfly
REM If that doesn't work and you get "Access Denied" error - Try: fsutil reparsepoint delete D:\opt\Wildfly

REM Lets get out of here!
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%