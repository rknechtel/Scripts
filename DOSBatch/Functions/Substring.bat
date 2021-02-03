
REM ************************************************************************
REM Function: Substring
REM Author: Richard Knechtel
REM Date: 10/18/2018
REM Description: This function will allow you to substring a string\
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM ************************************************************************

:Substring
::Substring(retVal,string,startIndex,length)
:: extracts the substring from string starting at startIndex for the specified length  SET string=%2%  SET startIndex=%3%  SET length=%4%
 
 if "%4" == "0" goto :noLength
 CALL SET _substring=%%string:~%startIndex%,%length%%%
 goto :substringResult
 :noLength
 CALL SET _substring=%%string:~%startIndex%%%
 :substringResult
 set "%~1=%_substring%"
GOTO :EOF