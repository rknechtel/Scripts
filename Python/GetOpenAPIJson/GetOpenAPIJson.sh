#!/bin/bash

##!/bin/sh

# ************************************************************************
# Script: GetOpenAPIJson.sh
# Author: Richard Knechtel
# Date: 02/12/2021
# Description: This script will allow you get the JSON from an OpenAPI
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# Example Call:
# GetOpenAPIJson.sh dev My-Service
#
# ************************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
echo "Parameters Passed = " $1 $2
echo

# set ENVIRONMENT=%1
APINAME=$1
JSONURL=$2

# Check if we got ALL parameters
if [ $# -eq 0 ]  || [ -z "$APINAME" ] || [ -z "$JSONURL" ] 
 then
  echo "[USAGE]: GetOpenAPIJson.sh arg1 arg2"
  echo "arg1 = APINAME (Example:  My-Service)"
  echo "arg2 = JSONURL (Example: https://devapache.my.com/my-service/v2/api-docs?group=public-api)"
  exit 1
fi


# set Script Path
# set SCRIPTPATH=C:\Scripts\Python\GetOpenAPIJson
SCRIPTPATH=/opt/Scripts/Python/GetOpenAPIJson

echo

echo "*********************************************************************************************************"
echo "Starting GetOpenAPIJson"
echo "*********************************************************************************************************"

python3 $SCRIPTPATH\GetOpenAPIJson.py $APINAME $JSONURL

# Lets get out of here!
exit 0

# END
