
@ECHO OFF
REM ************************************************************************
REM Script: EncryptDatasourcepw.bat
REM Author: Richard Knechtel
REM Date: 09/08/2015
REM Description: This script will encrypt a plain text Password for 
REM              use in DataSources
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM ************************************************************************

echo Running as user: %USERNAME%

set "PW=%1"

if not defined PW  (
 echo "Usage: EncryptDatasourcepw [plain text password]"
 Echo "Example: EncryptDatasourcepw MyPlainTextPassword"
 goto EXIT
)

java -cp %JBOSS_HOME%/modules/system/layers/base/org/picketbox/main/picketbox-4.0.21.Final.jar;%JBOSS_HOME%/modules/org/jboss/logging/main/jboss-logging-3.1.0.GA.jar;%CLASSPATH% org.picketbox.datasource.security.SecureIdentityLoginModule %PW%

rem Get exit code from process and exit:
set EXITCODE=%ERRORLEVEL%
echo "EXITCODE= " %EXITCODE%
goto EXIT

:EXIT
exit /B %EXITCODE%