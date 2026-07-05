#!/bin/bash
# *********************************************************************
# Script: checks3public.sh
# Author: Richard Knechtel
# Date: 05/21/2026
# Description: This will check for any S3 buckets with Public Access enabled.
#
# Note: Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Example Call (bash)
# source ./checks3public.sh
#
#
# *********************************************************************

# Check for buckets where public access is NOT fully blocked:
echo "Checking for any S3 Buckets with Public Access."
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text | tr '\t' '\n'); do
  result=$(aws s3api get-public-access-block --bucket "$bucket" 2>/dev/null)
  if echo "$result" | grep -q '"BlockPublicAcls": false\|"BlockPublicPolicy": false\|"IgnorePublicAcls": false\|"RestrictPublicBuckets": false'; then
    echo "⚠️  Potentially public: $bucket"
  elif [ -z "$result" ]; then
    echo "⚠️  No public access block configured: $bucket"
  else
    echo "✅ Blocked: $bucket"
  fi
done
