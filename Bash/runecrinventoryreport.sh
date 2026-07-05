#!/bin/bash
# *********************************************************************
# Script:runecrinventoryreport.sh
# Author: Richard Knechtel
# Date: 01/28/2026
# Description: This will get a list of ECR Repositories, Sizes and costs
#
# Parameters: 
#
# Note:
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Example Call (bash)
# ./runecrinventoryreport.sh
#
# *********************************************************************

#printf
#printf "Running as user: $USER"
#printf

# Get parameters
#printf Parameters Passed = $1
#printf


# Initialize grand totals
GRAND_TOTAL_IMAGES=0
GRAND_TOTAL_GB=0
COST_PER_GB=0.10 # Current AWS ECR storage cost per GB
REPORT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Get a list of all repository names
REPOS=$(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text)

echo "========================================================================"
echo "ECR INVENTORY REPORT (Count, Size and Cost)"
echo "Report Generated: $REPORT_DATE"
echo "========================================================================"
printf "%-40s %-10s %-12s %-10s\n" "REPOSITORY" "IMAGES" "SIZE (GB)" "COST/MO"
echo "------------------------------------------------------------------------"

for REPO in $REPOS; do
    # 1. 
    # Fetch raw data: Digest and Size in Bytes
    RAW_DATA=$(aws ecr describe-images --repository-name "$REPO" --query 'imageDetails[].[imageDigest, imageSizeInBytes]' --output text)

    # 2.
    # Count rows and sum bytes (Process using AWK)
    # This also calculates the cost for the specific repo
    STATS=$(echo "$RAW_DATA" | awk -v cost_rate="$COST_PER_GB" '
        {count++; sum+=$2} 
        END {
            gb = sum/1073741824;
            printf "%d %.3f %.2f", count, gb, gb*cost_rate
        }')

    REPO_COUNT=$(echo "$STATS" | awk '{print $1}')
    REPO_GB=$(echo "$STATS" | awk '{print $2}')
    REPO_COST=$(echo "$STATS" | awk '{print $3}')

    # 3. 
    # Handle empty ECR repositories
    if [[ -z "$RAW_DATA" ]]; then
        REPO_COUNT=0
        REPO_GB="0.000"
        REPO_COST="0.00"
    fi

    printf "%-40s %-10s %-12s $%-9s\n" "$REPO" "$REPO_COUNT" "$REPO_GB" "$REPO_COST"

    # 4. 
    # Add to Grand Totals (Bash math for integers, awk for floating point)
    GRAND_TOTAL_IMAGES=$((GRAND_TOTAL_IMAGES + REPO_COUNT))
    GRAND_TOTAL_GB=$(echo "$GRAND_TOTAL_GB $REPO_GB" | awk '{print $1 + $2}')
done

# Final Formatting of total cost for Grand Totals
TOTAL_COST=$(echo "$GRAND_TOTAL_GB $COST_PER_GB" | awk '{printf "%.2f", $1 * $2}')
YEARLY_COST=$(echo "$TOTAL_COST" | awk '{printf "%.2f", $1 * 12}')

echo "======================================================================"
echo "GRAND TOTAL IMAGES:   $GRAND_TOTAL_IMAGES"
echo "GRAND TOTAL STORAGE:  $(printf "%.3f" $GRAND_TOTAL_GB) GB"
echo "ESTIMATED MONTHLY COST (Standard \$0.10/GB): \$$TOTAL_COST"
echo "ESTIMATED YEARLY COST (\$$TOTAL_COST X 12): \$$YEARLY_COST"
echo "======================================================================"

