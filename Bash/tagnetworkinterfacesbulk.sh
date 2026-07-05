#!/bin/bash

# *********************************************************************
# Script: tagnetworkinterfacesbulk.sh
# Author: Richard Knechtel
# Date: 02/04/2026
# Description: This script will bulk update Tags on EC2 Network Interfaces
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [EC2.35] (EC2 network interfaces should be tagged)
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
#   ec2:DescribeNetworkInterfaces
#   ec2:CreateTags
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagnetworkinterfacesbulk.sh
# OR:
# ./tagnetworkinterfacesbulk.sh --dry-run
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
    echo "!! Example: ./tagnetworkinterfacesbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

echo "Fetching Network Interfaces..."

# Get ENI ID and Description
ENI_LIST=$(aws ec2 describe-network-interfaces --query 'NetworkInterfaces[*].[NetworkInterfaceId, Description]' --output text)

if [ -z "$ENI_LIST" ]; then
    echo "No Network Interfaces found."
    exit 0
fi

echo "$ENI_LIST" | while read -r ID DESC; do
    # Check if the ENI already has any tags
    TAG_COUNT=$(aws ec2 describe-network-interfaces --network-interface-ids "$ID" --query 'length(NetworkInterfaces[0].TagSet || `[]`)' --output text)
    echo "Tag Count = $TAG_COUNT"

    if [[ "$TAG_COUNT" -gt 0 ]]; then
        echo "Skipping $ID: Resource already has $TAG_COUNT tag(s)."
        continue
    fi

    # Determine the Value for the Name tag
    if [[ -z "$DESC" || "$DESC" == "None" || "$DESC" == $'\t' ]]; then
        TAG_VALUE="$ID"
    else
        TAG_VALUE="$DESC"
    fi

    # Logic for tagging or simulating
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would apply Name: '$TAG_VALUE' to ENI: $ID"
    else
        echo "Applying Name: '$TAG_VALUE' to ENI: $ID"
        aws ec2 create-tags --resources "$ID" --tags "Key=Name,Value=$TAG_VALUE"
    fi
done

echo "Process complete."