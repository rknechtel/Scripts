#!/bin/bash

# *********************************************************************
# Script: getcloudwatchevents.sh
# Author: Richard Knechtel
# Date: 06/04/2021
# Description: This will get CloudWatch Log Event
# Note: Need to manualy set the CloudWatch Log Group and Log Stream 
#       and start/end times.
#
#  Requires AWS CLI
#  Install AWS CLI in Linux:
#  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#  unzip awscliv2.zip
#  sudo ./aws/install
#
#
# Example Call (bash)
# ./getcloudwatchevents.sh "/aws/lambda/MyLambda/" "a2ebH56"
#
#
# *********************************************************************

GROUP=$1

# Log Streams:
# Log stream	Last event time
STREAM=$2

# Build epoch-millis (portable)
START=$(( $(date -d '2025-08-31T00:00:00Z' +%s) * 1000 ))   # GNU date
END=$((   $(date -d '2025-09-02T23:59:59Z' +%s) * 1000 ))

# If on macOS (BSD date), use:
# START=$(( $(date -j -f '%Y-%m-%dT%H:%M:%SZ' '2025-08-31T00:00:00Z' +%s) * 1000 ))
# END=$((   $(date -j -f '%Y-%m-%dT%H:%M:%SZ' '2025-09-02T23:59:59Z' +%s) * 1000 ))

echo "Log Group: $GROUP"
echo "Log Stream: $STREAM"
echo "Start Time: $START"
echo "End Time: $END"

# Page through until the token stops changing
TOKEN=""
while :; do
  RESP=$(aws logs get-log-events \
    --log-group-name "$GROUP" \
    --log-stream-name "$STREAM" \
    --start-time "$START" \
    --end-time "$END" \
    --start-from-head \
    ${TOKEN:+--next-token "$TOKEN"})
  echo "$RESP" | jq -r '.events[] | [.timestamp, .message] | @tsv'
  NEW=$(echo "$RESP" | jq -r '.nextForwardToken')
  [[ "$NEW" == "$TOKEN" ]] && break
  TOKEN="$NEW"
done

