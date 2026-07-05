#!/bin/bash

# *********************************************************************
# Script: finddbsecuritygroups.sh
# Author: Richard Knechtel
# Date: 06/04/2021
# Description: This will Find all AWS EC2 Security Groups for all
#              DEB Instnaces
#
# Example Call (bash)
# source finddbsecuritygroups.sh
#
# *********************************************************************

# Fetch all DB Instance Identifiers
# echo "Fetching all RDS instances..."
db_instances=$(aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text)

if [ -z "$db_instances" ]; then
    echo "No RDS instances found in this region."
    exit 0
fi

echo -e "----------------------------------------------------------"
echo "RDS Instance Security Groups"
echo -e "----------------------------------------------------------"
printf "%-30s | %-20s\n" "RDS Instance ID" "Security Group ID(s)"
echo -e "----------------------------------------------------------"

# Loop through each instance and get its security groups
for db_id in $db_instances; do
    sg_ids=$(aws rds describe-db-instances \
        --db-instance-identifier "$db_id" \
        --query "DBInstances[*].VpcSecurityGroups[*].VpcSecurityGroupId" \
        --output text)
    
    # Format output for readability
    printf "%-30s | %-20s\n" "$db_id" "$sg_ids"
done