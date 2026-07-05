#!/bin/bash

# *********************************************************************
# Script:getlambdas.sh
# Author: Richard Knechtel
# Date: 06/02/2025
# Description: This will get a list of Lambda Functions and total
#
# Parameters: 
#
# Note:
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Example Call (bash)
# ./getlambdas.sh
#
# *********************************************************************

#printf
#printf "Running as user: $USER"
#printf

echo "Fetching Lambda functions..."

# 1. Get the list of names
# 2. Get the total count
# Note: --max-items 10000 ensures you get more than the default page size of 50
FUNCTIONS=$(aws lambda list-functions --max-items 10000 --query 'Functions[].FunctionName' --output text)
COUNT=$(aws lambda list-functions --max-items 10000 --query 'length(Functions)' --output text)

echo "-------------------------------"
echo "LIST OF FUNCTIONS:"
echo "$FUNCTIONS" | tr '\t' '\n'
echo "-------------------------------"
echo "TOTAL COUNT: $COUNT"