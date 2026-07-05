#!/bin/bash

# *********************************************************************
# Script: cleanupelasticips.sh
# Author: Richard Knechtel
# Date: 02/05/2026
# Description: This script will look for unused Elastic IP's in all
#               Regions and remove them to save money ($$).
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
#   ec2:DescribeAddresses
#   ec2:DescribeRegions
#   ec2:ReleaseAddress
# - Run in all regions
#
# Example Call (bash)
# ./cleanupelasticips.sh
#
# *********************************************************************

#!/bin/bash

# Set to "true" to see what would happen without making changes
# Set to "false" to actually release the IPs
DRY_RUN=true

# Get a list of all enabled regions
REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

if [ "$DRY_RUN" = true ]; then
    echo "-----------------------------------------------------------------"
    echo "!!! DRY RUN MODE ENABLED - No IPs will be released !!!"
    echo "!! To release IP's set DRY_RUN variable in script to false !!"
    echo "-----------------------------------------------------------------"
    echo ""
fi

echo "-------------------------------------------"
echo "Starting cross-region Elastic IP scan..."
echo "-------------------------------------------"

for REGION in $REGIONS; do
    # Find Public IPs and Allocation IDs of EIPs where AssociationId is null
    # We grab both for better logging
    UNUSED_DATA=$(aws ec2 describe-addresses --region "$REGION" \
        --query "Addresses[?AssociationId==null].[PublicIp, AllocationId]" --output text)

    if [ -z "$UNUSED_DATA" ]; then
        continue # Skip to next region if nothing is found
    fi

    echo "Region: $REGION"

    while read -r PUBLIC_IP ALLOC_ID; do
        if [ "$DRY_RUN" = true ]; then
            echo "  [WOULD RELEASE] IP: $PUBLIC_IP (ID: $ALLOC_ID)"
        else
            echo "  [RELEASING] IP: $PUBLIC_IP (ID: $ALLOC_ID)..."
            aws ec2 release-address --region "$REGION" --allocation-id "$ALLOC_ID"
            
            if [ $? -eq 0 ]; then
                echo "    -> SUCCESS"
            else
                echo "    -> ERROR: Could not release"
            fi
        fi
    done <<< "$UNUSED_DATA"
done

echo "-------------------------------------------"
echo "Scan complete."