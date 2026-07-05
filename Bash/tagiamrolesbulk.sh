#!/bin/bash

# *********************************************************************
# Script: tagiamrolesbulk.sh
# Author: Richard Knechtel
# Date: 02/05/2026
# Description: This script will bulk update Tags on AWS ECS 
#              Task Definitions
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [IAM.24] (IAM roles should be tagged)
#
# Bash script to add the Tags:
# Adds these Tags if they don't exist:
# Name=IAM Role Name
# Terraform=False
#
# Parameters: 
# 
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
#   iam:ListRoles
#   iam:ListRoleTags
#   iam:TagRole
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagiamrolesbulk.sh
# OR:
# ./tagiamrolesbulk.sh --dry-run
# OR:
# ./tagiamrolesbulk.sh --dry-run
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
    echo "!! Example: ./tagiamrolesbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# Configuration
# Uncomment to use Logging
# LOG_FILE="iam_tagging_$(date +%Y%m%d_%H%M%S).log"

# Counters for Summary
COUNT_TAGGED=0
COUNT_SKIPPED=0
COUNT_FAILED=0
# COUNT_PROTECTED=0

# Uncomment to use Logging
# echo "Logging to: $LOG_FILE"
# echo "Starting IAM Role scan at $(date)" >> "$LOG_FILE"

echo "Fetching IAM roles..."
ROLES=$(aws iam list-roles --query 'Roles[*].RoleName' --output text)

for ROLE_NAME in $ROLES; do

     # SKIP PROTECTED ROLES: AWS SSO and Service-Linked Roles
    # if [[ "$ROLE_NAME" =~ ^AWSReservedSSO_ ]] || [[ "$ROLE_NAME" =~ ^AWSServiceRoleFor ]]; then
    #     echo "Ignoring protected AWS role: $ROLE_NAME" >> "$LOG_FILE"
    #     ((COUNT_PROTECTED++))
    #     continue
    # fi

    # Check if the role already has tags
    TAG_COUNT=$(aws iam list-role-tags --role-name "$ROLE_NAME" --query 'Tags | length(@)')

    if [ "$TAG_COUNT" -eq 0 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY RUN] Would tag role: $ROLE_NAME with Name=$ROLE_NAME, Terraform=False"
            # Uncomment to use Logging
            # MESSAGE="[DRY RUN] Role: $ROLE_NAME | Action: Would tag with Name=$ROLE_NAME, Terraform=False"
            # echo "$MESSAGE" | tee -a "$LOG_FILE"
        else
            echo "Tagging role: $ROLE_NAME..."
            aws iam tag-role --role-name "$ROLE_NAME" --tags \
                "Key=Name,Value=$ROLE_NAME" \
                "Key=Terraform,Value=False"
            
            if [ $? -eq 0 ]; then
                # Uncomment to use Logging
                # echo "[SUCCESS] Tagged $ROLE_NAME" >> "$LOG_FILE"
                echo "Successfully tagged $ROLE_NAME"
                ((COUNT_TAGGED++))
            else
                # Uncomment to use Logging
                # echo "[ERROR] Failed to tag $ROLE_NAME" | tee -a "$LOG_FILE"
                echo "Error: Failed to tag $ROLE_NAME"
                ((COUNT_FAILED++))
            fi
        fi
    else
        # Uncomment to use Logging
        # echo "Skipping $ROLE_NAME ($TAG_COUNT tags present)" >> "$LOG_FILE"
        echo "Skipping $ROLE_NAME ($TAG_COUNT tags already exist)"
        ((COUNT_SKIPPED++))
    fi
done

# Generate Summary Table
SUMMARY="
----------------------------------------
IAM TAGGING SUMMARY
----------------------------------------
Date: $(date)
Mode: $( [ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "LIVE" )
Roles Tagged/Targeted: $COUNT_TAGGED
Roles Skipped:         $COUNT_SKIPPED
# Roles Ignored (AWS):   $COUNT_PROTECTED
Failed Operations:     $COUNT_FAILED
Total Roles Scanned:   $((COUNT_TAGGED + COUNT_SKIPPED + COUNT_FAILED))
# Total Roles Scanned:    $((COUNT_TAGGED + COUNT_SKIPPED + COUNT_FAILED + COUNT_PROTECTED))
----------------------------------------"

# Uncomment to use Logging
# echo "$SUMMARY" | tee -a "$LOG_FILE"
# echo "Process complete. See $LOG_FILE for details."

echo "$SUMMARY"
echo "Process complete."
