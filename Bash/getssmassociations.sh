#!/bin/bash

# *********************************************************************
# Script: getssmassociations.sh
# Author: Richard Knechtel
# Date: 08/16/2022
# Description: This will get the SSM:
# Associations
# Associations Executions
# Associations Failures
#
# To get output into a file run script like:
# ./getssmassociations.sh >ssmassociations.txt
#
# *********************************************************************


echo "====================================================================================="

# 1. Fetch and display the full list of Association IDs
echo "============================================="
echo "SSM ASSOCIATION INVENTORY"
echo "============================================="
ASSOCIATION_IDS=$(aws ssm list-associations --query 'Associations[].AssociationId' --output text)

if [ -z "$ASSOCIATION_IDS" ]; then
    echo "No associations found in this region."
    exit 0
fi

echo "Found the following IDs:"
echo "----------------------------------------------------"
for ID in $ASSOCIATION_IDS; do
    echo "- $ID"
done

# Loop through each ID and describe its executions

echo "Listing executions for Associations"
echo "----------------------------------------------------"

for ID in $ASSOCIATION_IDS; do
    echo "Listing executions for Association: $ID"
    
    # We use --max-items 5 to keep the output readable, feel free to remove
    aws ssm describe-association-executions \
        --association-id "$ID" \
        --max-items 5 \
        --query 'AssociationExecutions[].{ID:AssociationId, ExecID:ExecutionId, Status:Status, Time:CreatedTime}' \
        --output table

    echo "----------------------------------------------------"
done

echo -e "\n============================================="
echo "SCANNING FOR FAILED EXECUTIONS"
echo "============================================="

# 2. Loop through each ID and filter for Failed status
echo "Scanning for failed executions and error messages..."
echo "----------------------------------------------------"

for ID in $ASSOCIATION_IDS; do
    echo "Checking Association: $ID"

    # Get the most recent Failed Execution ID
    # Note: Filter Key changed from 'ExecutionStatus' to 'Status'
    FAILED_EXEC_ID=$(aws ssm describe-association-executions \
        --association-id "$ID" \
        --filters "Key=Status,Value=Failed,Type=EQUAL" \
        --query 'AssociationExecutions[0].ExecutionId' \
        --output text)

    # Check if we actually found a failed execution
    if [ "$FAILED_EXEC_ID" != "None" ] && [ -n "$FAILED_EXEC_ID" ]; then
        echo "  [!] Found Failure in Execution: $FAILED_EXEC_ID"
        echo "  [!] Fetching specific error messages..."

        # 3. Get the error output for that specific failure
        aws ssm describe-association-execution-targets \
            --association-id "$ID" \
            --execution-id "$FAILED_EXEC_ID" \
            --query 'AssociationExecutionTargets[?Status==`Failed`].{InstanceId:ResourceId, ErrorSnippet:Output}' \
            --output table
    else
        echo "  [✓] No failed executions found for this association."
    fi
    echo "---------------------------------------------"
done
