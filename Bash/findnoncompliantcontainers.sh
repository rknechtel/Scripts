
#!/bin/bash

# *********************************************************************
# Script: findnoncompliantcontainers.sh
# Author: Richard Knechtel
# Date: 02/04/2026
# Description: This script will find all non-compliant containers in
#              ECS that don't have read-only root filesystems.
#
# This script is to remidiate:
# AWS Foundational Security Best Practices v1.0.0
# [ECS.5] (ECS containers should be limited to read-only access to root filesystems)
#
# Parameters: None
#
# Note:
#       Requires program: jq
#       sudo apt-get install -y jq
#
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
# ./findnoncompliantcontainers.sh
#
# *********************************************************************

# Ensure you have 'jq' installed for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it to run this script."
    exit 1
fi

echo "--------------------------------------------------------------------------------------------------"
echo "The following containers DO NOT have Read-Only root filesystems."
echo "They are non-compliant with:"
echo "AWS Foundational Security Best Practices v1.0.0"
echo "[ECS.5] (ECS containers should be limited to read-only access to root filesystems)"
echo "--------------------------------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------------------------------"
printf "%-20s | %-25s | %-20s | %-10s\n" "Cluster" "Service" "Container Name" "Read-Only?"
echo "--------------------------------------------------------------------------------------------------"

# 1. Get all Cluster ARNs
CLUSTERS=$(aws ecs list-clusters --query 'clusterArns' --output text)

for CLUSTER in $CLUSTERS; do
    CLUSTER_NAME=$(echo $CLUSTER | cut -d'/' -f2)
    
    # 2. Get all Service ARNs for each cluster
    SERVICES=$(aws ecs list-services --cluster "$CLUSTER" --query 'serviceArns' --output text)
    
    for SERVICE in $SERVICES; do
        SERVICE_NAME=$(echo $SERVICE | cut -d'/' -f3)
        
        # 3. Get the Task Definition for the service
        TASK_DEF_ARN=$(aws ecs describe-services --cluster "$CLUSTER" --services "$SERVICE" \
            --query 'services[0].taskDefinition' --output text)
        
        # 4. Describe Task Definition to check 'readonlyRootFilesystem'
        # Note: If the field is missing, it defaults to 'false' (non-compliant)
        aws ecs describe-task-definition --task-definition "$TASK_DEF_ARN" \
            --query 'taskDefinition.containerDefinitions[]' --output json | \
            jq -c '.[]' | while read -r container; do
                
                NAME=$(echo "$container" | jq -r '.name')
                READONLY=$(echo "$container" | jq -r '.readonlyRootFilesystem // "false"')
                
                # Highlight non-compliant containers in red if terminal supports it
                if [ "$READONLY" == "false" ]; then
                    READONLY_STATUS="\033[0;31mFALSE\033[0m"
                else
                    READONLY_STATUS="\033[0;32mTRUE\033[0m"
                fi

                printf "%-20s | %-25s | %-20s | %b\n" "$CLUSTER_NAME" "$SERVICE_NAME" "$NAME" "$READONLY_STATUS"
            done
    done
done
