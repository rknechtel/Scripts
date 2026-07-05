#!/bin/bash
# *********************************************************************
# Script: getroute53info.sh
# Author: Richard Knechtel
# Date: 12/15/2021
# Description: This will get route53 information
#
# Parameters: DNS Name
#
# Note: Requires program: jq
#       sudo apt-get install -y jq
#
#       Requires AWS CLI
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Immportant: These work in Bash - they have issues in ZShell.
#
# Example Call (bash)
# ./getroute53info.sh <DNS_NAME>
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo
echo "Note: Must be authenticated to AWS to run this!"
echo

# Get parameters
echo Parameters Passed = $1
echo

DNS_NAME=$1

usage()
{
  echo "[USAGE]: getroute53info.sh arg1"
  echo "arg1 = DNS Name (Example: mydomain.net)"
  echo "NOTE: Requires AWSCLI and program jq !"
}

# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${DNS_NAME}" ]; then
  usage
  return 1
fi

# Get Hosted Zone Infor for the DNS Name:
echo "Route53 Info for DNS Name: $DNS_NAME"

aws route53 list-hosted-zones-by-name --dns-name $DNS_NAME --no-cli-pager

echo

# Get Number of Hosted Zones:
count=$(aws route53 list-hosted-zones-by-name --dns-name $DNS_NAME | jq -r .HostedZones | jq length)
echo "Number of Hosted Zones for $DNS_NAME = $count"
echo

for (( index = 0; index < $count; index++ )) 
do

  HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name $DNS_NAME | jq -r .HostedZones[$index].Id |  awk '{ print substr( $0, 13 ) }')
  echo "Hosted Zone ID = $HOSTED_ZONE_ID"
  echo

  # List all Hosted Zone Resource Records:
  echo "Hosted Zone Resource Records for Hosted Zone ID $HOSTED_ZONE_ID: "
  aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --no-cli-pager

  echo

done

echo
echo "Done with getting Route53 Infomration for $DNS_NAME."
echo