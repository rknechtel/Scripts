#!/bin/bash

# *********************************************************************
# Script: awsvpnlookup.sh
# Author: Richard Knechtel
# Date: 03/17/2026
# Description: Looks up an AWS VPN Network Interface by private IP and 
#              enriches the output with a human-readable Client-VPN name 
#              based on the VPN endpoint ID found in the Description field.
#
# Parameters: IP Address
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
# Usage: ./awsvpnlookup.sh <IP_ADDRESS>
#
# *********************************************************************



set -euo pipefail

echo
echo "Running as user: $USER"
echo

# --- Validate input -----------------------------------------------------------
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <IP_ADDRESS>" >&2
  exit 1
fi

IP_ADDRESS="$1"

# Basic IP address format validation
if ! [[ "$IP_ADDRESS" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Error: '$IP_ADDRESS' does not look like a valid IPv4 address." >&2
  exit 1
fi

# --- VPN endpoint map ---------------------------------------------------------
# Add or remove entries here as needed.
declare -A VPN_MAP=(
  ["cvpn-endpoint-0a26153a3d9177d85"]="aws-vpn.mycompany.com"
  ["cvpn-endpoint-0c0f07ad452c61be2"]="aws-vpn-contractors.mycompany.com"
)

# --- Run AWS CLI --------------------------------------------------------------
echo "Looking up network interface for IP: ${IP_ADDRESS} ..." >&2

RAW_JSON=$(aws ec2 describe-network-interfaces \
  --filters "Name=addresses.private-ip-address,Values=${IP_ADDRESS}" \
  --query "NetworkInterfaces[*].{ID:NetworkInterfaceId,Description:Description,Type:InterfaceType,Owner:OwnerId,VPC:VpcId}" \
  --output json)

# Check if anything was returned
if [[ "$RAW_JSON" == "[]" || -z "$RAW_JSON" ]]; then
  echo "No network interfaces found for IP address: ${IP_ADDRESS}" >&2
  exit 0
fi

# --- Enrich each entry with Client-VPN label ----------------------------------
# jq walk-through:
#   For every object in the array, read its Description field,
#   extract the EndpointID value (format: "..., EndpointID: cvpn-endpoint-xxx"),
#   look it up in the shell associative array, and inject a "Client-VPN" key.

ENRICHED_JSON="$RAW_JSON"

for endpoint_id in "${!VPN_MAP[@]}"; do
  vpn_name="${VPN_MAP[$endpoint_id]}"
  ENRICHED_JSON=$(echo "$ENRICHED_JSON" | jq \
    --arg eid "$endpoint_id" \
    --arg vname "$vpn_name" \
    '
    map(
      if (.Description // "" | test($eid))
      then . + {"Client-VPN": $vname}
      else .
      end
    )
    ')
done

echo "The IP $IP_ADDRESS is associated with the VPN $ENRICHED_JSON"

