REM ************************************************************************
REM Function: StrLength
REM Author: Richard Knechtel
REM Date: 10/18/2018
REM Description: This function will allow you to check the length of a string
REM
REM LICENSE: 
REM This script is in the public domain, free from copyrights or restrictions.
REM
REM ************************************************************************

:StrLength
::StrLength(retVal,string)
::returns the length of the string specified in %2 and stores it in %1 set #=%2% set length=0 :stringLengthLoop if defined # (set #=%#:~1%&set /A length += 1&goto stringLengthLoop) ::echo the string is %length% characters long!
set "%~1=%length%"
GOTO :EOF