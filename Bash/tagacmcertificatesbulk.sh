#!/bin/bash

# *********************************************************************
# Script: tagacmcertificatesbulk.sh
# Author: Richard Knechtel
# Date: 02/04/2026
# Description: This script will bulk update Tags on SNS Topics
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [ACM.3] (ACM certificates should be tagged)
#
# Bash script to add the Tags:
# Adds these Tags if they don't exist:
# Name=Domain Name
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
# ./tagacmcertificatesbulk.sh
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
    echo "!! Example: ./tagacmcertificatesbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# Fetch all ACM Certificate ARNs
echo "Searching for ACM Certificates..."
CERT_ARNS=$(aws acm list-certificates --query 'CertificateSummaryList[].CertificateArn' --output text)

for ARN in $CERT_ARNS; do
    # Get the Domain Name
    DOMAIN_NAME=$(aws acm describe-certificate --certificate-arn "$ARN" --query 'Certificate.DomainName' --output text)
    
    # Clean the name: Remove ONLY the '*' if it exists at the start
    # Example: *.example.com becomes .example.com
    TAG_VALUE=${DOMAIN_NAME#\*}

    # Check for existing tags
    TAG_CHECK=$(aws acm list-tags-for-certificate --certificate-arn "$ARN" --query 'Tags' --output text)

    if [ -z "$TAG_CHECK" ] || [ "$TAG_CHECK" == "None" ]; then
        echo "Untagged Certificate found: $DOMAIN_NAME (Tagging as: $TAG_VALUE)"
      # APPLY TAGS
      if [ "$DRY_RUN" = true ]; then
        echo "  - [DRY RUN] Would apply tags: $TAGS_TO_ADD"
      else
        echo "  - Applying tags..."
        # Apply tags using the cleaned TAG_VALUE
        aws acm add-tags-to-certificate \
            --certificate-arn "$ARN" \
            --tags Key=Name,Value="$TAG_VALUE" Key=Terraform,Value=False
            
        echo "Successfully tagged $DOMAIN_NAME"
      fi
    else
        echo "Skipping $DOMAIN_NAME: Already has tags."
    fi
done

echo "ACM Tagging complete."