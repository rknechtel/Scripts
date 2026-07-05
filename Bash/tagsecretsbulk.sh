#!/bin/bash

# *********************************************************************
# Script: tagsecretsbulk.sh
# Author: Richard Knechtel
# Date: 02/04/2026
# Description: This script will bulk update Tags on Secrets in 
#              Secrets Manager.
#              It will add: Environment and Terrafrom Tags
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [SecretsManager.5] (Secrets Manager secrets should be tagged)
#
# Bash script to add the tag Key=Environment, Value=<ENVIRONMENT>
# to all AWS Secrets Manager secrets in region us-east-1
# Adds these Tags if they don't exist:
# Key=Terraform, Value=False
# Key=Environment, Value=<ENVIRONMENT>
# Key=Name, Value=<SECRET NAME>
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
# - AWS CLI installed and configured with appropriate permissions:
#   secretsmanager:ListSecrets
#   secretsmanager:TagResource
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagsecretsbulk.sh
# OR:
# ./tagsecretsbulk.sh --dry-run
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
    echo "!! Example: ./tagsecretsbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi


# Define the prefixes we are looking for
# Note: dev-1/ through dev-4/ are covered by the pattern logic below
echo "Fetching list of secrets..."
# We now fetch Tags in the initial list to reduce API calls inside the loop
SECRET_DATA=$(aws secretsmanager list-secrets --query 'SecretList[*].{ARN:ARN,Name:Name,Tags:Tags}' --output json)

if [[ -z "$SECRET_DATA" || "$SECRET_DATA" == "[]" ]]; then
    echo "No secrets found."
    exit 0
fi

# Iterate through secrets using jq for robust parsing
echo "$SECRET_DATA" | jq -c '.[]' | while read -r secret; do
    ARN=$(echo "$secret" | jq -r '.ARN')
    NAME=$(echo "$secret" | jq -r '.Name')
    # Count how many tags currently exist
    TAG_COUNT=$(echo "$secret" | jq '.Tags | length')

    echo "Processing secret: $NAME"

    # SKIPPING LOGIC: If the secret already has tags, we skip it entirely as per your request
    if [ "$TAG_COUNT" -gt 0 ]; then
        echo "  - Secret already has $TAG_COUNT tags. Skipping."
        continue
    fi

    # Initialize tags to add
    TAGS_TO_ADD="Key=Name,Value=$NAME Key=Terraform,Value=False"

    # ENVIRONMENT TAG LOGIC
    if [[ $NAME =~ ^(dev|dev-1|dev-2|dev-3|dev-4|qa|staging|prod)/ ]]; then
        ENV_VALUE="${BASH_REMATCH[1]}"
        echo "  - Prefix match found: $ENV_VALUE"
        TAGS_TO_ADD="$TAGS_TO_ADD Key=Environment,Value=$ENV_VALUE"
    fi

    # APPLY TAGS
    if [ "$DRY_RUN" = true ]; then
        echo "  - [DRY RUN] Would apply tags: $TAGS_TO_ADD"
    else
        echo "  - Applying tags..."
        aws secretsmanager tag-resource --secret-id "$ARN" --tags $TAGS_TO_ADD
    fi

done

echo "Process complete."