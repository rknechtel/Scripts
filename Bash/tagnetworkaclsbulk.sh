#!/bin/bash

# *********************************************************************
# Script: tagnetworkaclsbulk.sh
# Author: Richard Knechtel
# Date: 02/04/2026
# Description: This script will bulk update Tags on Network ACL's
#
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [EC2.41] (EC2 network ACLs should be tagged)
#
# Bash script to add the Tags:
# Same tags as the VPC
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
#   sqs:ListQueues
#   sqs:ListQueueTags
#   sqs:TagQueue
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagnetworkaclsbulk.sh.sh
#
# *********************************************************************

echo "Searching for untagged Network ACLs..."

# 1. Find all NACL IDs that have no tags
NACL_IDS=$(aws ec2 describe-network-acls \
    --query 'NetworkAcls[?Tags==`[]` || Tags == null].NetworkAclId' \
    --output text)

if [ -z "$NACL_IDS" ] || [ "$NACL_IDS" == "None" ]; then
    echo "No untagged Network ACLs found."
    exit 0
fi

for NACL_ID in $NACL_IDS; do
    echo "------------------------------------------"
    echo "Processing NACL: $NACL_ID"

    # 2. Get the VPC ID associated with this NACL
    VPC_ID=$(aws ec2 describe-network-acls \
        --network-acl-ids "$NACL_ID" \
        --query 'NetworkAcls[0].VpcId' \
        --output text)

    echo "Associated VPC: $VPC_ID"

    # 3. Fetch all tags from the VPC in JSON format
    # We filter out any tags that might cause issues (rare, but safe practice)
    VPC_TAGS=$(aws ec2 describe-vpcs \
        --vpc-ids "$VPC_ID" \
        --query 'Vpcs[0].Tags' \
        --output json)

    # 4. Check if the VPC actually has tags to copy
    if [ "$VPC_TAGS" == "null" ] || [ "$VPC_TAGS" == "[]" ]; then
        echo "Warning: Parent VPC has no tags to copy. Skipping $NACL_ID."
        continue
    fi

    # 5. Apply the VPC's tags to the NACL
    echo "Mirroring tags from VPC to NACL..."
    aws ec2 create-tags \
        --resources "$NACL_ID" \
        --tags "$VPC_TAGS"

    echo "Successfully updated $NACL_ID"
done

echo "------------------------------------------"
echo "NACL Tag Mirroring complete!"