#!/bin/bash

# *********************************************************************
# Script: getecsips.sh
# Author: Richard Knechtel
# Date: 06/04/2021
# Description: This will get the Public and Private IP's of all
#              ECS containers.
#
#  Requires AWS CLI
#  Install AWS CLI in Linux:
#  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#  unzip awscliv2.zip
#  sudo ./aws/install
#
#
# Example Call (bash)
# source getecsips.sh Cluster-services Cluster-services Cluster-operations
#
#
# *********************************************************************

CLUSTERSERVICES=$1
CLUSTERINTEGRATIONS=$2
CLUSTEROPERATIONS=$3
REGION=us-east-1

echo 
echo "Get ENI IDs for running Fargate tasks in the services cluster:"
ENIS=$(aws ecs describe-tasks --region "$REGION" --cluster "$CLUSTERSERVICES" --tasks $(aws ecs list-tasks --region "$REGION" --cluster "$CLUSTERSERVICES" --desired-status RUNNING --query 'taskArns[]' --output text) --query "tasks[?launchType=='FARGATE'].attachments[?type=='ElasticNetworkInterface'].details[?name=='networkInterfaceId'].value[]" --output text)
aws ec2 describe-network-interfaces --region "$REGION" --network-interface-ids $ENIS --query "NetworkInterfaces[].{ENI:NetworkInterfaceId, Subnet:SubnetId, AZ:AvailabilityZone, PrivateIPv4:PrivateIpAddress, PublicIPv4:Association.PublicIp, IPv6s: join(', ', Ipv6Addresses[].Ipv6Address)  }" --output table

echo 
echo "Get ENI IDs for running Fargate tasks in the integrations cluster:"
ENIS=$(aws ecs describe-tasks --region "$REGION" --cluster "$CLUSTERINTEGRATIONS" --tasks $(aws ecs list-tasks --region "$REGION" --cluster "$CLUSTERINTEGRATIONS" --desired-status RUNNING --query 'taskArns[]' --output text) --query "tasks[?launchType=='FARGATE'].attachments[?type=='ElasticNetworkInterface'].details[?name=='networkInterfaceId'].value[]" --output text)
aws ec2 describe-network-interfaces --region "$REGION" --network-interface-ids $ENIS --query "NetworkInterfaces[].{ENI:NetworkInterfaceId, Subnet:SubnetId, AZ:AvailabilityZone, PrivateIPv4:PrivateIpAddress, PublicIPv4:Association.PublicIp, IPv6s: join(', ', Ipv6Addresses[].Ipv6Address)  }" --output table

echo 
echo "Get ENI IDs for running Fargate tasks in the operations cluster:"
ENIS=$(aws ecs describe-tasks --region "$REGION" --cluster "$CLUSTEROPERATIONS" --tasks $(aws ecs list-tasks --region "$REGION" --cluster "$CLUSTEROPERATIONS" --desired-status RUNNING --query 'taskArns[]' --output text) --query "tasks[?launchType=='FARGATE'].attachments[?type=='ElasticNetworkInterface'].details[?name=='networkInterfaceId'].value[]" --output text)
aws ec2 describe-network-interfaces --region "$REGION" --network-interface-ids $ENIS --query "NetworkInterfaces[].{ENI:NetworkInterfaceId, Subnet:SubnetId, AZ:AvailabilityZone, PrivateIPv4:PrivateIpAddress, PublicIPv4:Association.PublicIp, IPv6s: join(', ', Ipv6Addresses[].Ipv6Address)  }" --output table


