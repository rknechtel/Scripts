#!/bin/bash
# *********************************************************************
# Script: getiamusermfadevices.sh
# Author: Richard Knechtel
# Date: 05/10/2022
# Description: This will get a list of IAM users with MFA Devices.
#
# Parameters: 
#
# Note: Requires program: jq
#       sudo apt-get install -y jq
#
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Immportant: These work in Bash - they have issues in ZShell.
#
# Example Call (bash)
# getiamusermfadevices.sh
#
# Example pipe to a file:
# getiamusermfadevices.sh >iamusersmfadevices.txt
#
#
# *********************************************************************

#echo
#echo "Running as user: $USER"
#echo

# Get parameters
#echo Parameters Passed = $1
#echo

# Get list of IAM Users
IAM_USERS=(`aws iam list-users --max-items 100 | jq -r .Users[].UserName`)

for iamuser in "${IAM_USERS[@]}" ; do
  echo "$iamuser"
  aws iam list-mfa-devices --user-name $iamuser
done

