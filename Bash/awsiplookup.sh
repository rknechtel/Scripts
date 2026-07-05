#!/bin/bash

# *********************************************************************
# Script: awsiplookup.sh
# Author: Richard Knechtel
# Date: 03/24/2026
# Description: Looks up an AWS IP address to find the service it 
#              belongs to.
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
# AWS IP Range Lookup — supports /12, /22, /24 (and any valid CIDR)
# Usage: ./aws_ip_lookup.sh <ip>[/<cidr>] [<ip>[/<cidr>] ...]
# Default CIDR: /24
# Examples:
#   ./aws_ip_lookup.sh 3.233.158.45
#   ./aws_ip_lookup.sh 3.233.158.45/24
#   ./aws_ip_lookup.sh 3.232.0.0/12
#   ./aws_ip_lookup.sh 3.236.92.0/22
#
# *********************************************************************
# AWS IP Range Lookup
# Usage: ./aws_ip_lookup.sh [ip_prefix ...]
# Default prefixes if none provided
#
# Specific IPs
# ./aws_ip_lookup.sh 3.233.158.45 3.236.94.12
#
# Mix of IPs
# ./aws_ip_lookup.sh 52.219.169.42 13.248.105.99
# *********************************************************************

set -euo pipefail

IP_RANGES_URL="https://ip-ranges.amazonaws.com/ip-ranges.json"
NO_MATCH_IPS=()  # accumulates IPs with no AWS match

usage() {
  echo "Usage: $0 <ip>[/<cidr>] [<ip>[/<cidr>] ...]"
  echo ""
  echo "  Default CIDR: /24"
  echo ""
  echo "  Examples:"
  echo "    $0 3.233.158.45"
  echo "    $0 3.233.158.45/24"
  echo "    $0 3.232.0.0/12"
  echo "    $0 3.236.92.0/22"
  exit 1
}

[[ $# -eq 0 ]] && usage

# Convert dotted IPv4 to integer
ip_to_int() {
  local IFS='.'
  read -r a b c d <<< "$1"
  echo $(( (a << 24) | (b << 16) | (c << 8) | d ))
}

# Convert integer back to dotted IPv4
int_to_ip() {
  local n=$1
  echo "$(( (n >> 24) & 255 )).$(( (n >> 16) & 255 )).$(( (n >> 8) & 255 )).$(( n & 255 ))"
}

# Download ip-ranges.json once
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

echo "Fetching AWS IP ranges from: $IP_RANGES_URL"
echo "-------------------------------------------"
if ! curl -sf "$IP_RANGES_URL" -o "$TMP"; then
  echo "ERROR: Failed to download ip-ranges.json" >&2
  exit 1
fi

echo "Sync Token : $(jq -r '.syncToken' "$TMP")"
echo "Created    : $(jq -r '.createDate' "$TMP")"
echo ""

for INPUT in "$@"; do
  # Parse optional CIDR suffix (default /24)
  if [[ "$INPUT" =~ ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/([0-9]+)$ ]]; then
    RAW_IP="${BASH_REMATCH[1]}"
    CIDR="${BASH_REMATCH[2]}"
  elif [[ "$INPUT" =~ ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})$ ]]; then
    RAW_IP="${BASH_REMATCH[1]}"
    CIDR=24
  else
    echo "WARNING: '$INPUT' is not a valid IPv4 or IPv4/CIDR — skipping." >&2
    continue
  fi

  # Validate CIDR range
  if (( CIDR < 1 || CIDR > 32 )); then
    echo "WARNING: /$CIDR is out of range (1–32) — skipping." >&2
    continue
  fi

  # Compute network address and broadcast
  IP_INT=$(ip_to_int "$RAW_IP")
  MASK=$(( 0xFFFFFFFF ^ ((1 << (32 - CIDR)) - 1) ))
  NET_INT=$(( IP_INT & MASK ))
  BCAST_INT=$(( NET_INT | (~MASK & 0xFFFFFFFF) ))

  echo "========================================"
  echo "Input     : $INPUT"
  echo "Network   : $(int_to_ip $NET_INT)/${CIDR}"
  echo "Range     : $(int_to_ip $NET_INT) — $(int_to_ip $BCAST_INT)"
  echo "========================================"

  # Use jq to find all AWS prefixes that contain the query network.
  # Avoids bash bitwise ops in jq by using floor-division to simulate masking:
  #   ip & mask  ==  floor(ip / block) * block   (where block = 2^(32-cidr))
  RESULTS=$(jq -r --argjson qip "$IP_INT" '
    .prefixes[] |
    (.ip_prefix | split("/")) as $parts |
    ( $parts[0] | split(".") | map(tonumber) |
      .[0] * 16777216 + .[1] * 65536 + .[2] * 256 + .[3]
    ) as $aws_ip |
    ($parts[1] | tonumber) as $aws_cidr |
    (pow(2; 32 - $aws_cidr) | floor) as $block |
    select( ($aws_ip / $block | floor) == ($qip / $block | floor) ) |
    "  IP Prefix : \(.ip_prefix)\n  Service   : \(.service)\n  Region    : \(.region)\n  NBG       : \(.network_border_group)\n"
  ' "$TMP")

  if [[ -z "$RESULTS" ]]; then
    echo "  No matches found."
    NO_MATCH_IPS+=("$RAW_IP")
  else
    echo "$RESULTS"
  fi
done

# Summary of unmatched IPs + country lookup
echo ""
if [[ ${#NO_MATCH_IPS[@]} -eq 0 ]]; then
  echo "All IPs matched an AWS range."
else
  echo "========================================"
  echo "IPs with NO AWS match (${#NO_MATCH_IPS[@]} total)"
  echo "========================================"
  for ip in "${NO_MATCH_IPS[@]}"; do
    echo "  $ip"
  done

  echo "========================================"
  echo "IPs with NO AWS match (${#NO_MATCH_IPS[@]} total) — looking up country via ipinfo.io..."
  echo "========================================"
  printf "  %-18s %-5s %-20s %s\n" "IP" "CC" "Country" "Org"
  echo "  $(printf '%.0s-' {1..70})"

  # Note: If we get: lookup failed (HTTP 429)
  # 429 means we're hitting ipinfo.io's rate limit hard.
  for ip in "${NO_MATCH_IPS[@]}"; do
    RESPONSE=$(curl -s --max-time 10 \
      -H "Accept: application/json" \
      "https://ipinfo.io/${ip}/json" \
      -w "\nHTTPSTATUS:%{http_code}" 2>&1) || true

    HTTP_CODE=$(echo "$RESPONSE" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    BODY=$(echo "$RESPONSE" | sed '/HTTPSTATUS:[0-9]*/d')

    if [[ "$HTTP_CODE" != "200" ]]; then
      printf "  %-18s  lookup failed (HTTP %s)\n" "$ip" "${HTTP_CODE:-no response}"
      continue
    fi

    COUNTRY=$(echo "$BODY" | jq -r '.country // "??"')
    ORG=$(echo "$BODY"     | jq -r '.org     // "unknown"')

    # Map country code to full name via a second jq field if available,
    # otherwise just show the code
    COUNTRY_NAME=$(echo "$BODY" | jq -r 'if .country then .country else "Unknown" end')

    printf "  %-18s %-5s %-20s %s\n" "$ip" "$COUNTRY" "$COUNTRY_NAME" "$ORG"

    # Stay within ipinfo.io free rate limit (~1 req/sec sustained)
    sleep 0.3
  done
fi

echo ""
echo "Done."