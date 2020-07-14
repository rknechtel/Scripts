
@echo off

setlocal EnableDelayedExpansion

REM ************************************************************************
REM Script: ConvertE2A.bat
REM Author: Richard Knechtel
REM Date: 10/04/2018
REM Description: This script will batch convert files from EBCIDIC to ASCII
REM
REM Example Call: 
REM ConvertE2A.bat D:\Scripts\ConvertEBCDIC2ASCII\FilesToConvert D:\Scripts\ConvertEBCDIC2ASCII\FilesConverted
REM 
REM To Build Jar:
REM Download .zip from:
REM https://github.com/SonarSource/ebcdic-to-ascii-converter
REM 
REM Extract the directory: ebcdic-to-ascii-converter-master
REM CD to the Directory: ebcdic-to-ascii-converter-master
REM
REM Required to build:
REM Java 8
REM Maven
REM
REM Run:
REM mvn clean package
REM The Jar will be in:
REM ebcdic-to-ascii-converter-master\target
REM
REM ************************************************************************

echo.
echo Running as user: %USERNAME%
echo.
echo Note: This script MUST be run as ADMINISTRATOR!
echo.

REM Get parameters
set DIROFFILESTOCONVERT=%1
set DIROFFILESCONVERTED=%2


REM Check if we got ALL parameters
if "!DIROFFILESTOCONVERT!"=="" goto usage
if "!DIROFFILESCONVERTED!"=="" goto usage
if "!DIROFFILESTOCONVERT!"=="" if "!DIROFFILESCONVERTED!"=="" (
   goto usage
)

set JAVA_HOME=D:\Scripts\ConvertEBCDIC2ASCII\Java\jdk1.8.0_45
REM Set up CLASSPATH
set CLASSPATH=%JAVA_HOME%\lib\tools.jar;%JAVA_HOME%\jre\lib\rt.jar;
REM Set up PATH
set PATH=%PATH%;%JAVA_HOME%\bin;

java -jar D:\Scripts\ConvertEBCDIC2ASCII\ebcdic-ascii-converter-0.2-SNAPSHOT.jar %DIROFFILESTOCONVERT% %DIROFFILESCONVERTED%


REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: ConvertE2A.bat arg1 arg2
echo arg1 = Directory of Files to Convert (Example: D:\Scripts\ConvertEBCDIC2ASCII\FilesToConvert) 
echo arg2 = Directory Converted Files go to (Example: D:\Scripts\ConvertEBCDIC2ASCII\FilesConverted) 
goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORNUMBER%
