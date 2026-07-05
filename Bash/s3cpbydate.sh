#!/bin/bash

# *********************************************************************
# Script: s3cpbydate.sh
# Author: Richard Knechtel
# Date: 12/09/2024
# Description: This get a list of S3 objects based on a date/time range
#              and copy them to the specified output directory location.
#
# Parameters: 
# Source S3 Bucket
# Source S3 Folder/Folder Key
# Start Date/Timestamp
# End Date/Timestamp
# Output Directory
#
# IMPORTANT: You must be authenticated to AWS to run this.
#
# Note: Requires AWk and Perl
#
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
#
# Template of Call (bash):
# ./s3cpbydate.sh <SOURCE_BUCKET> <SOURCE_FOLDER_KEY> <START_TIMESTAMP> <END_TIMESTAMP> <OUTPUT_DIRECTORY>
#
# Example of Call (bash):
# Local path:
# ./s3cpbydate.sh "s3://company-s3-server-logging" "company123456789012/us-east-1/company/2024/12/01/" "2024-11-30 21:40:00" "2024-11-30 22:00:00" "~/Downloads/S3Downloads"
# ./s3cpbydate.sh "s3://company-s3-server-logging" "company123456789012/us-east-1/company/2024/12/01/" "2024-11-30 21:40:00" "2024-11-30 22:00:00" "/home/user1/Downloads/S3Downloads"
#
# S3 path:
# ./s3cpbydate.sh "s3://company-s3-server-logging" "company123456789012/us-east-1/company/2024/12/01/" "2024-11-30 21:40:00" "2024-11-30 22:00:00" "s3://mybackupbucket"
#
# *********************************************************************

echo parameters passed: $1 $2 $3 $4 $5

SOURCE_BUCKET=$1
SOURCE_FOLDER_KEY=$2
START_TIMESTAMP=$3 # In format: YYYY-MM-DD HH:MM:SS
END_TIMESTAMP=$4 # In format: YYYY-MM-DD HH:MM:SS
OUTPUT_DIRECTORY=$5

if [[ $OUTPUT_DIRECTORY == *"~"* ]]; then
  eval OUTPUT_DIRECTORY=$OUTPUT_DIRECTORY
fi


usage()
{
  echo "[USAGE]: s3cpbydate.sh arg1 arg2 arg3 arg4 arg5"
  echo "arg1 = S3 Source Bucket (Example: s3://mycompany-s3-server-logging)"
  echo "arg2 = Source Folder Key (Example: (from  Keepass --> <Key Name> --> KeeOtp2 --> Copy TOTP) )"
  echo "arg3 = Start Timestamp (In format: YYYY-MM-DD HH:MM:SS) (Example: 2024-11-30 21:40:00)"
  echo "arg4 = End Timestamp (In format: YYYY-MM-DD HH:MM:SS) (Example: 2024-11-30 22:00:00)"
  echo "arg5 = Output Directory (Example: ~/Downloads/S3Downloads OR s3://mybackupbucket)"
  echo "NOTE: Requires AWS CLI, AWK and Perl!"
}


# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${SOURCE_BUCKET}" ]  && [ -z "${SOURCE_FOLDER_KEY}" ]  && [ -z "${START_TIMESTAMP}" ]  && [ -z "${END_TIMESTAMP}" ] && [ -z "${OUTPUT_DIRECTORY}" ]; then
 usage
 return 1 
fi

echo "Getting list of S3 objects:"
content=$(aws s3 ls $SOURCE_BUCKET/$SOURCE_FOLDER_KEY --recursive | awk '$0 >"'"${START_TIMESTAMP}"'" {print $0}' | awk '$0 <"'"${END_TIMESTAMP}"'" {print $0}' | perl -pe 's/^(?:\S+\s+){3}//')

echo "Copying S3 objects:"
for file in $content;
do
  # echo $SOURCE_BUCKET/$file
  aws s3 cp $SOURCE_BUCKET/$file $OUTPUT_DIRECTORY
done
