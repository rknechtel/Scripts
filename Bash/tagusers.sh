#!/bin/bash
# *********************************************************************
# Script: tagusers.sh
# Author: Richard Knechtel
# Date: 05/10/2022
# Description: This will put tags on AWS IAM Users
#
# Parameters: None
#
# Note: Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Immportant: These work in Bash - they have issues in ZShell.
#
# NOTE: You need to add AWS IAM Users and the Tags to this script.
#
#
# Example Call (bash)
# ./tagusers.sh
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo
echo "Note: Must be authenticated to AWS to run this!"
echo

# Put Tags on AWS Users
echo
echo "Start Putting Tags on AWS IAM Users"
echo

# echo "tagging me"
# aws iam tag-user --cli-input-json '{"UserName": "me", "Tags":[{"Key":"Team","Value":"Engineering Team"},{"Key":"CostCenter","Value":"1234"},{"Key":"UserType","Value":"mycompany Employee"},{"Key":"Environment","Value":"All"}]}'



echo
echo "Done with putting Tags on AWS IAM Users"
echo
