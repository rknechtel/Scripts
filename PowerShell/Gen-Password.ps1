# -----------------------------------------------------------------------------
# Script Name: Gen-Password.ps1
# Description: Will generate a random password
# Author: Richard Knechtel
# Date: 08/28/2024
# Notes:
# Ported to PowerShell from my Bash script
#
# Parameters:
# pComplexity
# pLength
#
# pComplexity:
# There is three levels of complexity:
#  1 = Uppercase letters and lowercase letters
#  2 = 1 plus numbers
#  3 = 2 plus special characters
# Default is 3
#
# pLength:
# determines the amount of characters in the resultant password.
# Default is 10
#
# Examples Calling this Script:
#
# Calling the script without parameters:
# ./Gen-Password.ps1
# Example Output:
# {I5u3^!bXv
#
# Complexity 1, length 15
# ./Gen-Password.ps1 1 15
# Example Output:
# WGXtMchibgYkEJB
#
# Complexity 3, length 20
# ./Gen-Password.ps1 3 20
# Example Output:
# ?5*dOR1$H09xc4g]]NDY
#
# -----------------------------------------------------------------------------

param (
    [int]$pComplexity = 3,
    [int]$pLength = 10
)

# Define character sets
$upperLower = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
$numbers    = "0123456789"
$special    = '!@#$%^&*()_+-=[]{}|;:,.<>/?'

# Determine the character pool
switch ($pComplexity) {
    1 { $charSet = $upperLower }
    2 { $charSet = $upperLower + $numbers }
    Default { $charSet = $upperLower + $numbers + $special }
}

# Generate the password
$password = ""
for ($i = 0; $i -lt $pLength; $i++) {
    $password += $charSet[(Get-Random -Minimum 0 -Maximum $charSet.Length)]
}

# Output to console AND copy to clipboard
Write-Host "Generated Password: " -NoNewline
Write-Host $password -ForegroundColor Cyan
$password | Set-Clipboard

Write-Host "Password has been copied to your clipboard!" -ForegroundColor Green
