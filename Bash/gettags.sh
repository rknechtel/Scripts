#!/bin/bash
# *********************************************************************
# Script: gettags.sh
# Author: Richard Knechtel
# Date: 05/10/2022
# Description: This will get the tags on AWS IAM Users
#
# Parameters: None
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
# NOTE: You need to add AWS IAM Users to this script.
#
#
# Example Call (bash)
# ./gettags.sh
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo
echo "Note: Must be authenticated to AWS to run this!"
echo

# Get the Tags for AWS Users
echo
echo "Start Getting Tags for AWS IAM Users"
echo

aws iam list-user-tags --user-name me | jq -c >meTags.json

echo
echo "Done with getting Tags for AWS IAM Users"
echo
