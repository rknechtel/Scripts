#!/bin/bash

# *********************************************************************
# Script: tagecsservicesbulk.sh
# Author: Richard Knechtel
# Date: 02/05/2026
# Description: This script will bulk update Tags on AWS ECS Services
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [ECS.13] (ECS services should be tagged)
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
#   ecs:ListClusters
#   ecs:ListServices
#   ecs:ListTagsForResource
#   ecs:TagResource
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagecsservicesbulk.sh
# OR:
# ./tagecsservicesbulk.sh --dry-run
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
    echo "!! Example: ./tagecsservicesbulk.sh --dry-run !!!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

# Fetch all ECS cluster ARNs
clusters=$(aws ecs list-clusters --query 'clusterArns' --output text)

for cluster_arn in $clusters; do
    cluster_name=$(basename "$cluster_arn")
    echo "Processing Cluster: $cluster_name"

    # Get Cluster Tags
    cluster_tags=$(aws ecs list-tags-for-resource --resource-arn "$cluster_arn" --query 'tags' --output json)

    if [ "$cluster_tags" == "[]" ] || [ -z "$cluster_tags" ]; then
        echo "  - No tags found on cluster. Skipping."
        continue
    fi

    # List all services in this cluster
    services=$(aws ecs list-services --cluster "$cluster_arn" --query 'serviceArns' --output text)

    for service_arn in $services; do
        service_name=$(basename "$service_arn")
        
        # Check if the service already has tags
        service_tag_count=$(aws ecs list-tags-for-resource --resource-arn "$service_arn" --query 'length(tags)')

        if [ "$service_tag_count" -eq 0 ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "  [DRY RUN] Would tag service: $service_name"
            else
                echo "  - Service $service_name has no tags. Applying cluster tags..."
                aws ecs tag-resource --resource-arn "$service_arn" --tags "$cluster_tags"
                
                if [ $? -eq 0 ]; then
                    echo "    - Successfully tagged!"
                else
                    echo "    - Failed to tag service."
                fi
            fi
        else
            echo "  - Service $service_name already has tags. Skipping."
        fi
    done
done
