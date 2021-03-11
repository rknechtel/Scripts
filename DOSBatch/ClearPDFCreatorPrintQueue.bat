
@echo off
setlocal EnableDelayedExpansion
REM *********************************************************************
REM Script: ClearPDFCreatorPrintQueue.bat
REM Author: Richard Knechtel
REM Date: 02/18/2021
REM Description: This will Clear the PDF Creater Print Queue
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

set ERRORNUMBER=0

REM Clear PDF Creater Print Queue
C:
CD "C:\Program Files (x86)\PDFCreator"
pdfcreator.exe /CLEARCACHE
CD C:\

REM Lets get out of here!
goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
