

@echo off
setlocal enableDelayedExpansion
REM *******************************************************************
REM Script Name: UpdateText.bat
REM Description: This will update All occurances of text in a .json file
REM Author: Richard Knechtel 
REM Date: 09/09/2020
REM  
REM Parameters:
REM            Full File Path (Example: D:\Work\MyFileToUpdate.txt)
REM            Text To be Updated (Example: MyTextToUpdate)
REM            Text To Replace With (Example: TextToReplaceWith)
REM
REM Example Call:
REM   UpdateText.bat D:\work ServerA ServerB
REM
REM *******************************************************************

REM @echo on

set ERRORNUMBER=0

REM Get next FilePath
set FILEPATH=%1

REM Get hostname
set TEXTTOFIND=%2

REM Server and Service Location
set TEXTTOREPLACE=%3


REM Check if we got BOTH parameters
if "!FILEPATH!"=="" goto usage
if "!TEXTTOFIND!"=="" goto usage
if "!TEXTTOREPLACE!"=="" goto usage
if "!FILEPATH!"=="" if "!TEXTTOFIND!"=="" if "!TEXTTOREPLACE!"=="" (
   goto usage
)


REM Replace all occurences of Text
for %%f in (%FILEPATH%\*.json) do (
  echo searching and replacing all occurences of %TEXTTOFIND% with %TEXTTOREPLACE% in %%f
  echo powershell -Command "(gc %%f) -replace '%TEXTTOFIND%', '%TEXTTOREPLACE%' | Out-File %%f"
  powershell -Command "(gc %%f) -replace '%TEXTTOFIND%', '%TEXTTOREPLACE%' | Out-File %%f"
)

REM ****************************************************************************************


REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: UpdateText.bat arg1 arg2 arg3
echo arg1 = Full File Path (D:\Work\FileToUpdate.json)
echo arg2 = Text To Be Replaced (MyTextToChange)
echo arg3 = Replacement Text (ReplacedText)

goto getoutofhere

:getoutofhere
Exit /B %ERRORNUMBER%
