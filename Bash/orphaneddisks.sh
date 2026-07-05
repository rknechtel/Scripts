#!/bin/bash
# *********************************************************************
# Script: orphaneddisks.sh
# Author: Richard Knechtel
# Date: 09/24/2025
# Description: This will generate a list of orphaned disks
#
# Parameters: None
#
# Note: You must have active AWS Access keys for this to work and MFA enabled and setup.
#
# Note: You MUST have mfa_serial set in your .aws/config file.
# Example:
# [default]
# region = ${AWS_REGION}
# output = json
# mfa_serial=arn:aws:iam::123456789012:mfa/MyMFADevice
#
# Note:
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Example Call (bash)
# ./orphaneddisks.sh
#
#
# *********************************************************************

# *********************************************************************
# Note: 
# Replace: 123456789012
# With your AWS Account Number
# *********************************************************************


AWS_REGION=us-east-1

# You can display snapshots that are not tied to an AMI by running the following command.

# Get snapshot list  
aws ec2 describe-snapshots --owner-ids self --region=${AWS_REGION} --filters "Name=description,Values=*ami-*" "Name=storage-tier,Values=standard" --query 'Snapshots[].[SnapshotId]' --output text | sort > snapshot.txt

# Obtaining a snapshot associated with AMI  
aws ec2 describe-images --owners self --region=${AWS_REGION} --query "Images[].BlockDeviceMappings[].Ebs.[SnapshotId]" --output text | sort > ami-snapshot.txt

# Compare files and display snapshots with no AMI associated
echo "EBS Snapshots with no AMI associated to them:"
comm -23 snapshot.txt ami-snapshot.txt

# Other Commands:
# aws ec2 describe-snapshots --owner-ids self --region=${AWS_REGION} --filters "Name=storage-tier,Values=standard" --query 'Snapshots[*].{SnapshotId:SnapshotId, Description:Description, VolumeSize:VolumeSize,Name:Tags[?Key==`Name`]|[0].Value}' --output table
# aws ec2 describe-volumes --region ${AWS_REGION} --filters Name=status,Values=available --query 'Volumes[].[VolumeId]' --output table
# aws ec2 describe-volumes --region ${AWS_REGION} --filters Name=status,Values=available --query 'Volumes[].[VolumeId]' --output text | wc -l
# aws ec2 describe-volumes --query "Volumes[?State=='available'].{ID:VolumeId,Size:Size}" --output table
# aws ec2 describe-volumes --query "Volumes[?State=='available'].{ID:VolumeId,SnapshotId:SnapshotId,Size:Size}" --output table


