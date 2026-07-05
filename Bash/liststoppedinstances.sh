#!/bin/bash

# *********************************************************************
# Script: liststoppedinstances.sh
# Author: Richard Knechtel
# Date: 02/05/2026
# Description: This script will list all stopped EC2 Instances
#
# Parameters: 
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
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./liststoppedinstances.sh.sh
#
# *********************************************************************
 
# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it to continue."
    exit 1
fi

echo "Searching for stopped EC2 instances..."
echo "--------------------------------------------------------------------------------"

# Fetching the instances using a specific JMESPath query
INSTANCES_TABLE=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=stopped" \
    --query 'Reservations[*].Instances[*].{ID: InstanceId, State: State.Name, Type: InstanceType, Name: Tags[?Key==`Name`].Value | [0]}' \
    --output table)

INSTANCES_TABLE=${INSTANCES_TABLE/DescribeInstances/Stopped Instances}
 echo "$INSTANCES_TABLE"

echo "--------------------------------------------------------------------------------"
