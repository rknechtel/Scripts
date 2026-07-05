#!/bin/bash

# *********************************************************************
# Script: tagecstaskdefinitionsbulk.sh
# Author: Richard Knechtel
# Date: 02/05/2026
# Description: This script will bulk update Tags on AWS ECS 
#              Task Definitions
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [ECS.15] (ECS task definitions should be tagged)
#
# Bash script to add the Tags:
# Adds these Tags if they don't exist:
# Name=CloudFormation Stack Name
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
#   ecs:ListTaskDefinitions
#   ecs:DescribeClusters
#   ecs:ListTagsForResource
#   ecs:TagResource
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagecstaskdefinitionsbulk.sh
# OR:
# ./tagecstaskdefinitionsbulk.sh --dry-run
#
# *********************************************************************

echo "=================================================================="
echo "Note: This script will Tag any ECS Task Definition"
echo "      That does not have Tags in any Region on any ECS Cluster"
echo "=================================================================="

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
    echo "!! Example: ./tagecstaskdefinitionsbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# Get all enabled regions
REGIONS=$(aws ec2 describe-regions --all-regions --query "Regions[?OptInStatus!='not-opted-in'].RegionName" --output text)

for REGION in $REGIONS; do
    echo -e "\n--> Checking Region: $REGION"

    # Get all Cluster ARNs
    CLUSTER_ARNS=$(aws ecs list-clusters --region "$REGION" --query 'clusterArns[]' --output text)

    for CLUSTER_ARN in $CLUSTER_ARNS; do
        CLUSTER_NAME=$(basename "$CLUSTER_ARN")
        
        # 1. Fetch Cluster Tags
        CLUSTER_TAGS=$(aws ecs list-tags-for-resource --resource-arn "$CLUSTER_ARN" --region "$REGION" --query 'tags' --output json)

        if [ "$CLUSTER_TAGS" == "[]" ] || [ -z "$CLUSTER_TAGS" ]; then
            continue
        fi

        # 2. Get all Task Definition ARNs
        TASK_DEF_ARNS=$(aws ecs list-task-definitions --region "$REGION" --query 'taskDefinitionArns[]' --output text)

        for TD_ARN in $TASK_DEF_ARNS; do
            # 3. Check if Task Definition is untagged
            TD_TAGS_COUNT=$(aws ecs list-tags-for-resource --resource-arn "$TD_ARN" --region "$REGION" --query 'length(tags)')

            if [ "$TD_TAGS_COUNT" -eq 0 ]; then
                if [ "$DRY_RUN" = true ]; then
                    echo "    [WOULD TAG] $TD_ARN with tags from $CLUSTER_NAME"
                else
                    echo "    [TAGGING] $TD_ARN..."
                    aws ecs tag-resource \
                        --resource-arn "$TD_ARN" \
                        --region "$REGION" \
                        --tags "$CLUSTER_TAGS"
                fi
            fi
        done
    done
done

echo "--- ECS Task Definition Tagging Complete ---"
