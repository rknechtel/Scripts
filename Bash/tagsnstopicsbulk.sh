#!/bin/bash

# *********************************************************************
# Script: tagsnstopicsbulk.sh
# Author: Richard Knechtel
# Date: 02/04/2026
# Description: This script will bulk update Tags on SNS Topics
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [SNS.3] (SNS topics should be tagged)
#
# Bash script to add the Tags:
# Adds these Tags if they don't exist:
# Name=SQS Topic Name
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
#   sqs:ListQueues
#   sqs:ListQueueTags
#   sqs:TagQueue
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagsnstopicsbulk.sh
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
    echo "!! Example: ./tagsnstopicsbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# Fetch all SNS Topic ARNs
echo "Searching for SNS Topics..."
TOPIC_ARNS=$(aws sns list-topics --query 'Topics[].TopicArn' --output text)

for ARN in $TOPIC_ARNS; do
    # Extract the Topic Name from the ARN (the part after the last ':')
    TOPIC_NAME="${ARN##*:}"

    # Check for tags
    # SNS list-tags-for-resource returns an empty list [] if no tags exist
    TAG_CHECK=$(aws sns list-tags-for-resource --resource-arn "$ARN" --query 'Tags' --output text)

    if [ -z "$TAG_CHECK" ] || [ "$TAG_CHECK" == "None" ]; then
      echo "Untagged Topic found: $TOPIC_NAME"
      if [ "$DRY_RUN" = true ]; then
        echo "  - [DRY RUN] Would apply tags: Key=Name,Value="$TOPIC_NAME" Key=Terraform,Value=False"
      else
        echo "  - Applying tags..."
        # Apply tags using the tag-resource command
        # Syntax: Key=string,Value=string (comma separated)
        aws sns tag-resource \
            --resource-arn "$ARN" \
            --tags Key=Name,Value="$TOPIC_NAME" Key=Terraform,Value=False
            
        echo "Successfully tagged $TOPIC_NAME"
    else
        echo "Skipping $TOPIC_NAME: Already has tags."
    fi
done

echo "SNS Tagging complete."