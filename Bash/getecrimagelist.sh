#!/bin/bash
# *********************************************************************
# Script:getecrimagelist.sh
# Author: Richard Knechtel
# Date: 06/02/2025
# Description: This will get a list of ECR images
#
# Parameters: 
#
# Note: Requires program: jq
#       sudo apt-get install -y jq
#
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Immportant: These work in Bash - they have issues in ZShell.
#
# Example Call (bash)
# ./getecrimagelist.sh
#
# *********************************************************************

#printf
#printf "Running as user: $USER"
#printf

# Get parameters
#printf Parameters Passed = $1
#printf

# Initialize grand total
GRAND_TOTAL=0

echo "==============================================="
echo "ECR Repositories"
echo "==============================================="
ECR_REPOS=$(aws ecr describe-repositories --query 'repositories[].repositoryName' --output table)
ECR_REPOS=${ECR_REPOS/DescribeRepositories/Repositories        }
echo "$ECR_REPOS"


# Get a list of all repository names
REPOS=$(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text)

echo "======================================================================"
echo "ECR Image INVENTORY REPORT (Sorted by Date Descending)"
echo "======================================================================"

for REPO in $REPOS; do
    echo -e "\nRepository: $REPO"
    
    # Fetch image details and count
    # Note: Using describe-images to ensure we see tags and push dates
    # Sorts by imagePushedAt, then reverses to get Descending order	
    IMAGES_TABLE=$(aws ecr describe-images --repository-name "$REPO" \
     --query 'reverse(sort_by(imageDetails, &imagePushedAt))[*].{Tag:imageTags[0], PushedAt:imagePushedAt, Digest:imageDigest}' \
    --output table)
    IMAGES_TABLE=${IMAGES_TABLE/DescribeImages/Images        }

    # Calculate count using awk to sum all lines returned by the CLI
    # This handles the "100 100 6" issue by adding them together: 100+100+6
    REPO_COUNT=$(aws ecr describe-images --repository-name "$REPO" --query 'length(imageDetails)' --output text | awk '{sum+=$1} END {print sum}')
    
    # If the repo is empty, REPO_COUNT might be blank; default to 0
    REPO_COUNT=${REPO_COUNT:-0}

    # Print the image list
    echo "$IMAGES_TABLE"
    echo "Count for $REPO: $REPO_COUNT"
    
    # Add to grand total
    GRAND_TOTAL=$((GRAND_TOTAL + REPO_COUNT))
done


echo -e "\n==============================================="
echo "GRAND TOTAL IMAGES ACROSS ALL REPOS: $GRAND_TOTAL"
echo "==============================================="
