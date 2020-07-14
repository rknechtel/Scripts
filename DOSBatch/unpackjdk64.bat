@echo off

setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: unpackjdk64.bat
REM Author: Richard Knechtel
REM Date: 01/05/2016
REM Description: This will extract Java JDK from a Java JDK EXe installer
REM Parameter: Java JDK Installer exe file
REM
REM tools.zip located at:
REM .rsrc\1033\JAVA_CAB10\111
REM src.zip located at:
REM .rsrc\1033\JAVA_CAB9\110
REM
REM *********************************************************************

echo Running as user: %USERNAME%

REM Get parameters
@echo Parameters Passed = %1

set "JDKEXE=%1"

REM Check if we got ALL parameters
if "!JDKEXE!"=="" goto usage

set tool7z="C:\Program Files\7-Zip\7z.exe"
set JAVAROOTDIR=C:\opt\Java

set DIRNAME=%~n1
echo DIRNAME = %DIRNAME%

set FULLDIRNAME=%~dpn1
echo FULLDIRNAME = %FULLDIRNAME%

REM Get JDK Version as Directory
for /f "tokens=1,2,3 delims=-" %%a in ("%~n1") do set JDKDIR=%%a%%b
echo JDKDIR = %JDKDIR%

echo Extracting JDK
echo Extraction: %tool7z% x %JDKEXE% -aoa%DIRNAME%
%tool7z% x %JDKEXE% -aoa -o%DIRNAME%


echo cd dirname = "%DIRNAME%\.rsrc\1033\JAVA_CAB10"
cd "%DIRNAME%\.rsrc\1033\JAVA_CAB10"

echo Current dir = %cd%


REM Extract tools.zip
echo Extract tools.zip
echo Extracting '111'
extrac32 111

echo Removing '111'
del 111

echo Extracting 'tools.zip'
%tool7z% x tools.zip -o%JDKDIR%
 
echo Removing 'tools.zip'
del tools.zip

echo Extracting '*.pack'
cd %JDKDIR%
for /r %%x in (*.pack) do .\bin\unpack200 -r "%%x" "%%~dx%%~px%%~nx.jar"


REM Extract src.zip
echo Extract src.zip
echo cd dirname = "%FULLDIRNAME%\.rsrc\1033\JAVA_CAB9"
cd "%FULLDIRNAME%\.rsrc\1033\JAVA_CAB9"

echo Extracting '110'
extrac32 110

echo Removing '110'
del 110

move %FULLDIRNAME%\.rsrc\1033\JAVA_CAB9\src.zip %FULLDIRNAME%\.rsrc\1033\JAVA_CAB10\%JDKDIR%

echo %FULLDIRNAME%\.rsrc\1033\JAVA_CAB10
cd %FULLDIRNAME%\.rsrc\1033\JAVA_CAB10

echo.
echo Moving new JDK Dir: %JDKDIR% to your Java directory location: %JAVAROOTDIR%
mkdir %JAVAROOTDIR%\%JDKDIR%
xcopy /E /Y %FULLDIRNAME%\.rsrc\1033\JAVA_CAB10\%JDKDIR%\*.* %JAVAROOTDIR%\%JDKDIR%\*.*

echo.
echo.
echo Done.

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: unpackjdk64.bat arg1
echo arg1 = Java JDK EXE file (Example: jdk-8u221-windows-i586.exe)

goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
