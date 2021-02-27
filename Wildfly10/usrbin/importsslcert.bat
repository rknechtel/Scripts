
@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: importsslcert.bat
REM Author: Richard Knechtel
REM Date: 02/19/2021
REM Description: This will Import an SSL Cert into the Wildfly SSL Keystore
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM Notes:
REM       This MUST be run as Administrator!!!
REM *********************************************************************

echo Running as user: %USERNAME%
echo.
echo.
echo PLEASE NOTE: 
echo              This MUST be run as Administrator!!!
echo.
echo Note: SSL Cert Parameter must be the full path to the SSL Cert (No spaces in full file path)
echo.
echo.

set STOREPASS=%1
set ALIAS=%2
set SSLCERT=%3

REM Check if we got the parameter
REM Check if we got ALL parameters
if "!STOREPASS!"=="" goto usage
if "!ALIAS!"=="" goto usage
if "!SSLCERT!"=="" goto usage
if "!STOREPASS!"=="" if "!ALIAS!"=="" if "!SSLCERT!"=="" (
  goto usage
)


REM Import SSL Cert into Wildfly Keystore
keytool -keystore %JBOSS_HOME%\keystore\jbosscertstore.keystore -storepass %STOREPASS% -importcert -alias %ALIAS% -file %SSLCERT%


REM Lets get out of here!
goto getoutofhere


:usage
set ERRORNUMBER=1
echo [USAGE]: importsslcert.bat arg1 arg2 arg3
echo arg1 = SSL keystore Password (Example: My$$LK3y$t0r3P@$$w0rd)
echo arg2 = ALias for SSL Cert (Example: mydomain.com_cert)
echo arg3 = FUll File Path to SSL Certificate  (Example: D:\Temp\SSLCerts\mydomain.com.cert)
goto getoutofhere


:getoutofhere
Exit /B %ERRORNUMBER%
