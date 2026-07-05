#!/bin/bash

# *********************************************************************
# Script: awseniiplookup.sh
# Author: Richard Knechtel
# Date: 03/24/2026
# Description: Looks up an IP address against Public and Private IPs
#
# Parameters: IP Address
#
# Note: Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Usage: ./awseniiplookup.sh <IP_ADDRESS>
#
# *********************************************************************



set -euo pipefail

echo
echo "Running as user: $USER"
echo

# Usage check
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <IP-ADDRESS>"
    exit 1
fi

IP="$1"

# Basic IP format validation
if ! [[ "$IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Error: '$IP' does not appear to be a valid IP address."
    exit 1
fi

echo "=========================================="
echo " Public IP Lookup: $IP"
echo "=========================================="
aws ec2 describe-network-interfaces \
    --filters "Name=association.public-ip,Values=$IP" \
    --query "NetworkInterfaces[*].{ID:NetworkInterfaceId,Description:Description,Type:InterfaceType,Instance:Attachment.InstanceId}"

echo ""
echo "=========================================="
echo " Private IP Lookup: $IP"
echo "=========================================="
aws ec2 describe-network-interfaces \
    --filters "Name=addresses.private-ip-address,Values=$IP" \
    --query "NetworkInterfaces[*].{ID:NetworkInterfaceId,Description:Description,Type:InterfaceType,Owner:OwnerId,VPC:VpcId}"
