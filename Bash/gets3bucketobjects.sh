#!/bin/bash
# *********************************************************************
# Script: gets3bucketobjects.sh
# Author: Richard Knechtel
# Date: 08/16/2022
# Description: This will get the Number of Objects
#
# To get output into a file run script like:
# ./gets3bucketobjects.sh >s3bucketobjects.txt
#
# *********************************************************************

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
echo "S3 Object Count Report (via CloudWatch Metrics)"
echo "Note: CloudWatch storage metrics are updated once per day (usually at midnight UTC), so these numbers may be up to 24 hours old."
echo "-----------------------------------------------------------------------"
printf "%-50s %-20s\n" "Bucket Name" "Object Count"
echo "-----------------------------------------------------------------------"

GRAND_TOTAL_OBJECTS=0

for bucket in $BUCKETS; do
    # Get the Average value for NumberOfObjects
    # This metric always uses Dimension StorageType=AllStorageTypes
    count=$(aws cloudwatch get-metric-statistics \
        --namespace AWS/S3 \
        --metric-name NumberOfObjects \
        --dimensions Name=BucketName,Value="$bucket" Name=StorageType,Value="AllStorageTypes" \
        --start-time "$START_TIME" \
        --end-time "$END_TIME" \
        --period 86400 \
        --statistics Average \
        --query 'Datapoints[0].Average' \
        --output text)

    # Handle null/None results (convert to 0 and remove decimal points)
    if [ "$count" == "None" ] || [ -z "$count" ]; then
        count=0
    else
        # CloudWatch returns decimals for averages; we'll round to the nearest whole number
        count=$(printf "%.0f" "$count")
    fi

    printf "%-50s %-20s\n" "$bucket" "$count"

    # Add to Grand Total
    GRAND_TOTAL_OBJECTS=$((GRAND_TOTAL_OBJECTS + count))
done

echo "-----------------------------------------------------------------------"
printf "%-50s %-20s\n" "GRAND TOTAL OBJECTS:" "$GRAND_TOTAL_OBJECTS"
echo "-----------------------------------------------------------------------"
