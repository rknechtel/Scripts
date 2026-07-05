#!/bin/bash

# *********************************************************************
# Script: tagcloudformationstacksbulk.sh
# Author: Richard Knechtel
# Date: 02/05/2026
# Description: This script will bulk update Tags on AWS CloudFormation
#              Stacks.
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [CloudFormation.2] (CloudFormation stacks should be tagged)
#
# Bash script to add the Tags:
# Adds these Tags if they don't exist:
# Name=CloudFormation Stack Name
# Terraform=False
#
# Parameters: None
#
# Note:
#       Requires AWS CLI:
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Prerequisites:
# - AWS CLI installed
# - Configured with appropriate permissions:
#
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagcloudformationstacksbulk.sh
# OR:
# ./tagcloudformationstacksbulk.sh --dry-run
#
# *********************************************************************

# Set Dry Run:
DRY_RUN=false

echo "Dry Run Mode: $DRY_RUN"

# Check for dry-run flag
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [ "$DRY_RUN" = true ]; then
    echo "-----------------------------------------------------------------"
    echo "!!! DRY RUN MODE ENABLED - No Tags will be added !!!"
    echo "!! To add Tags set DRY_RUN variable in script to false !!"
    echo "-----------------------------------------------------------------"
    echo ""
else
    echo "-----------------------------------------------------------------"
    echo "!!! DRY RUN MODE DISABLED - Tags will be added !!!"
    echo "!! To only see what will change run script with --dry-fun flag !!"
    echo "!! Example: ./tagcloudformationstacksbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# We fetch the list and pipe it directly into a while loop. 
# This avoids the "for" loop expansion issues that cause character limit errors.
aws cloudformation describe-stacks --query 'Stacks[?StackStatus!=`DELETE_COMPLETE`].StackName' --output text | tr '\t' '\n' | while read -r stack_name; do

  # Skip empty lines
  [[ -z "$stack_name" ]] && continue

  echo "----------------------------------------------------"
  echo "Processing Stack: [$stack_name]"

  # 1. Get info for THIS stack only
  stack_info=$(aws cloudformation describe-stacks --stack-name "$stack_name" --query 'Stacks[0]' --output json)
    
  # 2. Extract and Prepare Parameters
  # We use jq to build the exact string AWS needs for each parameter
  param_args=()
  while read -r p; do
    [[ -n "$p" ]] && param_args+=("$p")
  done < <(echo "$stack_info" | jq -r '.Parameters // [] | .[] | "ParameterKey="+.ParameterKey+",UsePreviousValue=true"')

  # 3. Extract and Merge Tags
  # We pass the stack_name safely into jq using --arg
  tag_args=()
  while read -r t; do
    [[ -n "$t" ]] && tag_args+=("$t")
  done < <(echo "$stack_info" | jq -r --arg sn "$stack_name" '
      (.Tags // []) + 
      [{"Key": "Terraform", "Value": "False"}, {"Key": "Name", "Value": $sn}] 
      | unique_by(.Key) 
      | .[] | "Key="+.Key+",Value="+.Value')

  # APPLY TAGS
  if [ "$DRY_RUN" = true ]; then
        echo "  - [DRY RUN] Would apply tags: ${tag_args[@]}"
  else
    echo "  - Applying tags..."
    # 4. Execute the Update
    # The quotes around "$stack_name" and "${array[@]}" are non-negotiable
    aws cloudformation update-stack \
        --stack-name "$stack_name" \
        --use-previous-template \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND ${param_args:+--parameters "${param_args[@]}"} \
        --tags "${tag_args[@]}" 2>&1 | grep -v "No updates are to be performed"
  fi

done
