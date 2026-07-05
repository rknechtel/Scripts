#!/bin/bash

# *********************************************************************
# Script: tagelasticipsbulk.sh
# Author: Richard Knechtel
# Date: 02/05/2026
# Description: This script will bulk update Tags on Elastic IP's
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [EC2.37] (EC2 Elastic IP addresses should be tagged)
#
# Bash script to add the Tags:
# Adds these Tags if they don't exist:
# Key=Name, Value=<Network Interface Description OR EIP>
# Key=Terraform Value=False
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
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagelasticipsbulk.sh
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
    echo "!! Example: ./tagelasticipsbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# Get EIP details
EIP_LIST=$(aws ec2 describe-addresses --query 'Addresses[*].[AllocationId,PublicIp,NetworkInterfaceId]' --output text)

if [ -z "$EIP_LIST" ]; then
    echo "No Elastic IPs found."
    exit 0
fi

echo "$EIP_LIST" | while read -r ALLOC_ID IP ENI_ID; do
    
    echo "----------------------------------------------------"
    echo "Checking EIP: $IP ($ALLOC_ID)"

    # 1. Check if the EIP already has ANY tags
    TAG_COUNT=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$ALLOC_ID" --query 'length(Tags)' --output text)

    if [[ "$TAG_COUNT" -gt 0 ]]; then
        echo "  - [SKIP] Tags already exist ($TAG_COUNT found). Skipping to avoid overwriting."
        continue
    fi

    # 2. Determine Name Tag Value
    NAME_VALUE=""
    if [[ "$ENI_ID" != "None" && -n "$ENI_ID" ]]; then
        DESC=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI_ID" --query 'NetworkInterfaces[0].Description' --output text)
        
        if [[ -z "$DESC" || "$DESC" == "None" || "$DESC" == " " ]]; then
            NAME_VALUE="$IP"
            echo "  - ENI found but no description. Using IP as Name."
        else
            NAME_VALUE="$DESC"
            echo "  - Using ENI Description: '$DESC'"
        fi
    else
        NAME_VALUE="$IP"
        echo "  - EIP is unattached. Using IP as Name."
    fi

    # 3. Apply Tags (Conditional on Dry Run)
    if [ "$DRY_RUN" = true ]; then
        echo "  - [DRY RUN] Would add tags: Terraform=False, Name=$NAME_VALUE"
    else
        echo "  - [ACTION] Applying tags..."
        aws ec2 create-tags --resources "$ALLOC_ID" --tags Key=Terraform,Value=False "Key=Name,Value=$NAME_VALUE"
        echo "  - Done."
    fi

done

echo "----------------------------------------------------"
echo "Process complete."