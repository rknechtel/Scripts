#!/bin/bash
# *********************************************************************
# Script: gets3bucketsizes.sh
# Author: Richard Knechtel
# Date: 08/16/2022
# Description: This will get the Number of Objects and 
# Total Size of S3 buckets.
#
# To get output into a file run script like:
# ./gets3bucketsizes.sh >s3bucketsizes.txt
#
# *********************************************************************

# Note: Old way slow and exspensive.
# s3buckets=($(aws s3 ls | sed -E 's/ +/,/g' | cut -d ',' -f3))
# for s3bucket in "${s3buckets[@]}"
# do
#  echo "S3 Bucket: " $s3bucket
#  aws s3 ls s3://$s3bucket --recursive --human-readable --summarize | grep "Total" | sed -E 's/   //g'
#  echo " "
# done

# Note: New way - faster and cheaper.
# Define timeframe (CloudWatch S3 metrics are daily, so we look at the last 48 hours)
# Cross-platform Date Logic for CloudWatch (Last 2 Days)
if [[ "$OSTYPE" == "darwin"* ]]; then
    START_TIME=$(date -u -v-2d +%Y-%m-%dT%H:%M:%SZ)
else
    START_TIME=$(date -u --date='2 days ago' +%Y-%m-%dT%H:%M:%SZ)
fi
END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)


# Get all bucket names
BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

echo "-----------------------------------------------------------------------"
echo "S3 Bucket Size Report (via CloudWatch Metrics)"
echo "Note: CloudWatch storage metrics are updated once per day (usually at midnight UTC), so these numbers may be up to 24 hours old."
echo "-----------------------------------------------------------------------"
printf "%-40s %-15s %-15s\n" "Bucket Name" "Storage Type" "Size (GB)"
echo "-----------------------------------------------------------------------"


GRAND_TOTAL_GB=0

for bucket in $BUCKETS; do
    # Fetch storage types present for this bucket (Standard, Glacier, etc.)
    METRICS_JSON=$(aws cloudwatch list-metrics --namespace "AWS/S3" --metric-name "BucketSizeBytes" --dimensions Name=BucketName,Value="$bucket")
    STORAGE_TYPES=$(echo "$METRICS_JSON" | jq -r '.Metrics[].Dimensions[] | select(.Name=="StorageType") | .Value' | sort -u)

    if [ -z "$STORAGE_TYPES" ]; then
        continue
    fi

    for type in $STORAGE_TYPES; do
        size_bytes=$(aws cloudwatch get-metric-statistics \
            --namespace AWS/S3 \
            --metric-name BucketSizeBytes \
            --dimensions Name=BucketName,Value="$bucket" Name=StorageType,Value="$type" \
            --start-time "$START_TIME" \
            --end-time "$END_TIME" \
            --period 86400 \
            --statistics Average \
            --query 'Datapoints[0].Average' \
            --output text)

        # Skip buckets with no data or handle nulls
        if [ "$size_bytes" == "None" ] || [ -z "$size_bytes" ]; then
            size_bytes=0
        fi

        # Convert Bytes to GB (Bytes / 1024^3)
        size_gb=$(awk "BEGIN {printf \"%.2f\", $size_bytes/1073741824}")
        
        printf "%-40s %-15s %-15s\n" "$bucket" "$type" "$size_gb"

        # Update Grand Total using awk for floating point math
        GRAND_TOTAL_GB=$(awk "BEGIN {print $GRAND_TOTAL_GB + $size_gb}")
    done
done

echo "-----------------------------------------------------------------------"
printf "%-56s %-15s\n" "GRAND TOTAL ALL BUCKETS:" "$GRAND_TOTAL_GB GB"
echo "-----------------------------------------------------------------------"

