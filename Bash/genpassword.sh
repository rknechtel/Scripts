#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name: genpassword.sh
# Description: Will generate a random password
# Author: Richard Knechtel
# Date: 08/28/2024
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
# ./genpassword.sh
# Example Output:
# {I5u3^!bXv
#
# Complexity 1, length 15
# ./genpassword.sh 1 15
# Example Output:
# WGXtMchibgYkEJB
#
# Complexity 3, length 20
# ./genpassword.sh 3 20
# Example Output:
# ?5*dOR1$H09xc4g]]NDY

# -----------------------------------------------------------------------------


pComplexity=$1
pLength=$2
charSet=""

if [[ -z "$pLength" ]];then
 pLength=10
fi

if [[ $pComplexity == 1 ]]; then 
 charSet="A-Za-z"
elif [[ $pComplexity == 2 ]]; then
 charSet="A-Za-z0-9"
elif [[ $pComplexity == 3 ]]; then
 # charSet='A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~'
 charSet='A-Za-z0-9!#$%&\''()*+,-./:;<=>?@[\]^_{|}~'
# else
# charSet='A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~'
fi

tr -dc $charSet </dev/urandom | head -c $pLength;echo ''

