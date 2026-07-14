#!/bin/bash

# *********************************************************************
# Script: getipsallregions.sh
# Author: Richard Knechtel
# Date: 06/04/2021
# Description: This will get the Public and Private IP's in all Regions
#
#  Requires AWS CLI
#  Install AWS CLI in Linux:
#  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#  unzip awscliv2.zip
#  sudo ./aws/install
#
# Parameter: IP4 Address
#
# Example Call (bash)
# ./getipsallregions.sh
#
#
# *********************************************************************

set -euo pipefail
IP="${1:?Usage: $0 <ip>}"
for R in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  echo "=== $R ==="
  # public-ip association
  aws ec2 describe-network-interfaces --region "$R" \
    --filters Name=association.public-ip,Values="$IP" \
    --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Type:InterfaceType,Desc:Description,Instance:Attachment.InstanceId,PrivateIP:PrivateIpAddress,VPC:VpcId,Service:RequesterId}' \
    --output table
  # private-ip address
  aws ec2 describe-network-interfaces --region "$R" \
    --filters Name=addresses.private-ip-address,Values="$IP" \
    --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Type:InterfaceType,Desc:Description,Instance:Attachment.InstanceId,PrivateIP:PrivateIpAddress,VPC:VpcId,Service:RequesterId}' \
    --output table
  # Elastic IP (IPv4 only)
  if [[ "$IP" != *:* ]]; then
    aws ec2 describe-addresses --region "$R" --public-ips "$IP" \
      --query 'Addresses[].{AllocationId:AllocationId,AssociationId:AssociationId,ENI:NetworkInterfaceId,Instance:InstanceId,PrivateIP:PrivateIpAddress,Domain:Domain}' \
      --output table
  fi
done

