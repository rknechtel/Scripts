#!/bin/bash

# *********************************************************************
# Script: tagsqsqueuesbulk.sh
# Author: Richard Knechtel
# Date: 02/04/2026
# Description: This script will bulk update Tags on SQS Queues
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [SQS.2] (SQS queues should be tagged)
#
# Bash script to add the Tags:
# Adds these Tags if they don't exist:
# Key=Name, Value=<Network Interface ID>
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
# ./tagsqsqueuesbulk.sh
# OR:
# ./tagsqsqueuesbulk.sh --dry-run
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
    echo "!! Example: ./tagsqsqueuesbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# Fetch all SQS Queue URLs
echo "Searching for SQS Queues..."
QUEUE_URLS=$(aws sqs list-queues --query 'QueueUrls[]' --output text)

for URL in $QUEUE_URLS; do
  # Extract the Queue Name from the URL (the part after the last '/')
  QUEUE_NAME="${URL##*/}"

  # Check if the queue has any tags
  # We check if the 'Tags' key exists and is not empty
  TAG_CHECK=$(aws sqs list-queue-tags --queue-url "$URL" --query 'Tags' --output text)

  # If TAG_CHECK is empty or 'None', the queue has no tags
  if [ -z "$TAG_CHECK" ] || [ "$TAG_CHECK" == "None" ]; then
        
    # Check if the queue name contains the specific prefix
    if [[ "$QUEUE_NAME" == *"Q-"* ]]; then
            
      # Extract the text after 'XXXXXXXXXXXXXQ-'
      # Example: FeedOrchestratorServiceQ-dev-1 becomes 'dev-1'
      ENV_VALUE="${QUEUE_NAME#*Q-}"
            
      echo "Untagged queue found: $QUEUE_NAME"
      
      # APPLY TAGS
      if [ "$DRY_RUN" = true ]; then
        echo "  - [DRY RUN] Would apply tags: Environment=$ENV_VALUE, Terraform=False, Name=$QUEUE_NAME"
      else
        echo "Applying tags: Environment=$ENV_VALUE, Terraform=False, Name=$QUEUE_NAME"
        # Apply all three tags in a single command
        aws sqs tag-queue --queue-url "$URL" --tags Environment="$ENV_VALUE",Terraform=False,Name="$QUEUE_NAME"
      fi

    else
      echo "Skipping $QUEUE_NAME: Untagged, but does not match naming pattern."
    fi
  fi
done

echo "Script execution finished."
