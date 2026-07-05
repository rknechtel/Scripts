#!/bin/bash
# *********************************************************************
# Script: startstopec2.sh
# Author: Richard Knechtel
# Date: 08/05/2021
# Description: This will Start or Stop an EC2 instance
#
# Parameters: 
#             Command (start | stop)
#             EC2 Instance ID
#
#
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Example Call (bash)
# source startstopec2.sh <COMMAND> <EC2_INSTANCE_ID>
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
echo Parameters Passed = $1 $2
echo

COMMAND=$1
EC2_INSTANCE_ID=$2

usage()
{
  echo "[USAGE]: startstopec2.sh arg1 arg1"
  echo "arg1 = Command (stop | start)"
  echo "arg2 = EC2 Instance ID (Example: i-02440e682ee35abcb)"
}


# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${COMMAND}" ] && [ -z "${EC2_INSTANCE_ID}" ]; then
  usage
  return 1
fi


if [[ $COMMAND == "start" ]]; then
  echo "Starting EC2 Instance " $EC2_INSTANCE_ID
  aws ec2 start-instances --instance-ids $EC2_INSTANCE_ID
  
elif [[ $COMMAND == "stop" ]]; then
  echo "Stoping EC2 Instance " $EC2_INSTANCE_ID
  aws ec2 stop-instances --instance-ids $EC2_INSTANCE_ID

else
  echo "Invalid Command - Exiting!"

fi

# END of Script