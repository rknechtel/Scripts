#!/usr/bin/env bash

# *********************************************************************
# Script: s3storagesizes.sh.sh
# Author: Richard Knechtel
# Date: 01/12/2026
# Description: Count S3 objects by size threshold
# This version counts:
#   - <= 128KB (<= 131072 bytes)
#   - >  128KB (>  131072 bytes)
#
# Parameters: S3 Bucket Name
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
# Example Call (bash)
#   ./s3storagesizes.sh.sh my-bucket
#   ./s3storagesizes.sh.sh my-bucket --prefix some/path/ --profile prod --region us-west-2
#
# *********************************************************************

set -euo pipefail

echo
echo "Running as user: $USER"
echo

# Get parameters
#echo Parameters Passed = $1
#echo

BUCKET="${1:-}"

THRESHOLD_BYTES=131072 # 128 * 1024

usage()
{
  echo "[USAGE]: s3storagesizes.sh arg1"
  echo "arg1 = S3 Bucket Name (Example: my-bucket) [aws-cli-args...]"
  echo "NOTE: Requires AWS CLI and program jq!"
}


# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${BUCKET}" ]; then
 usage
 return 1 
fi

shift || true


if ! command -v aws >/dev/null 2>&1; then
  echo "Error: aws cli is required but not found in PATH." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not found in PATH." >&2
  exit 1
fi

AWS_ARGS=("$@")

le_count=0
gt_count=0
total_count=0

le_bytes=0
gt_bytes=0
total_bytes=0

token=""

while :; do
  cmd=(aws s3api list-objects-v2 --bucket "$BUCKET" --output json)
  cmd+=("${AWS_ARGS[@]}")
  [[ -n "$token" ]] && cmd+=(--continuation-token "$token")

  json="$("${cmd[@]}")"

  read -r p_le_count p_le_bytes p_gt_count p_gt_bytes p_total_count p_total_bytes < <(
    jq -r --argjson T "$THRESHOLD_BYTES" '
      ( .Contents // [] ) as $c
      | [
          ($c | map(select(.Size <= $T)) | length),
          ($c | map(select(.Size <= $T) | .Size) | add // 0),
          ($c | map(select(.Size >  $T)) | length),
          ($c | map(select(.Size >  $T) | .Size) | add // 0),
          ($c | length),
          ($c | map(.Size) | add // 0)
        ] | @tsv
    ' <<<"$json"
  )

  le_count=$((le_count + p_le_count))
  le_bytes=$((le_bytes + p_le_bytes))
  gt_count=$((gt_count + p_gt_count))
  gt_bytes=$((gt_bytes + p_gt_bytes))
  total_count=$((total_count + p_total_count))
  total_bytes=$((total_bytes + p_total_bytes))

  is_truncated="$(jq -r '.IsTruncated // false' <<<"$json")"
  [[ "$is_truncated" == "true" ]] || break

  token="$(jq -r '.NextContinuationToken // empty' <<<"$json")"
  [[ -n "$token" ]] || break
done

printf "Bucket: %s\n" "$BUCKET"
printf "Threshold: %d bytes (128 KB)\n\n" "$THRESHOLD_BYTES"
printf "Objects <= 128KB : %d (bytes total: %d)\n" "$le_count" "$le_bytes"
printf "Objects >  128KB : %d (bytes total: %d)\n" "$gt_count" "$gt_bytes"
printf "\nTotal objects     : %d (bytes total: %d)\n" "$total_count" "$total_bytes"
