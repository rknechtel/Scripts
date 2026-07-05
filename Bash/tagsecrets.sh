#!/bin/bash

# *********************************************************************
# Script: tagsecrets.sh
# Author: Richard Knechtel
# Date: 12/23/2025
# Description: 
# This script is to remidiate:
# AWS Resource Tagging Standard v1.0.0
# [SecretsManager.5] (Secrets Manager secrets should be tagged)
#
# Bash script to add the tag Key=Environment, Value=<ENVIRONMENT>
# to all AWS Secrets Manager secrets in region us-east-1
# whose ARN starts with arn:aws:secretsmanager:us-east-1:<Account_Number>:secret:<Environment>
# Adds tag Key=Environment, Value=ENVIRONMENT only if no existing tag with Key=Environment
#
# Parameters: 
# 1) Region
# Example: us-east-1
# 2) Account Number
# Example: 123456789011
# 3) Environment
# Examples: dev-1|dev-2|dev-3|dev-4|dev|qa|staging|prod
#
# Notes: 
# You must have active AWS Access keys for this to work and MFA enabled and setup.
# You MUST have mfa_serial set in your .aws/config file.
# Example:
# [default]
# region = us-east-1
# output = json
# mfa_serial=arn:aws:iam::123456789012:mfa/MyMFADevice
#
# Note:
#       Requires AWS CLI:
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
# Prerequisites:
# - AWS CLI installed and configured with appropriate permissions:
#   secretsmanager:ListSecrets
#   secretsmanager:TagResource
# - Run in the us-east-1 region (or set --region us-east-1 explicitly)
#
# Example Call (bash)
# ./tagsecrets.sh <REGION> <ACCOUNT_NUMBER> <ENVIRONMENT>
# ./tagsecrets.sh us-east-1 123456789012 prod
#
# *********************************************************************

# *********************************************************************
# Note: 
# Replace: 123456789012
# With your AWS Account Number
# *********************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
#echo Parameters Passed = $1 $2 $3
#echo

REGION=$1
ACCOUNT_NUMBER=$2
ENVIRONMENT=$3
ENVIRONMENT="${ENVIRONMENT,,}" # Converts to lowercase


usage()
{
  echo "[USAGE]: tagsecrets.sh arg1 arg2 arg3"
  echo "arg1 = Region (Example: us-east-1)"
  echo "arg2 = Account Number (Example: 123456789011)"
  echo "arg3 = Environment (Examples: dev-1|dev-2|dev-3|dev-4|dev|qa|staging|prod)"
  echo "NOTE: Requires AWS CLI!"
  echo "NOTE: NOTE2: You must have active AWS Access keys for this to work and MFA enabled and setup."
  echo "NOTE3: You MUST have mfa_serial set in your .aws/config file - see script for example"
}


# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${REGION}" ] && [ -z "${ACCOUNT_NUMBER}" ] && [ -z "${ENVIRONMENT}" ]; then
 usage
 return 1 
fi


ARN_PREFIX="arn:aws:secretsmanager:${REGION}:${ACCOUNT_NUMBER}:secret:${ENVIRONMENT}"
TAG_KEY="Environment"
TAG_VALUE=${ENVIRONMENT}


# List secret ARNs and filter by prefix (JMESPath starts_with)
mapfile -t SECRET_ARNS < <(aws secretsmanager list-secrets --region "${REGION}" --query "SecretList[?starts_with(ARN, \`${ARN_PREFIX}\`)].ARN" --output text | tr '\t' '\n')

if [[ ${#SECRET_ARNS[@]} -eq 0 ]]; then
  echo "No secrets found matching prefix."
  exit 0
fi


echo "Found ${#SECRET_ARNS[@]} secret(s). Checking tags..."
echo ""

UPDATED=0
SKIPPED=0

for arn in "${SECRET_ARNS[@]}"; do
  # Get tags for the secret (may be empty)
  existing_value="$(
    aws secretsmanager describe-secret \
      --region "${REGION}" \
      --secret-id "${arn}" \
      --query "Tags[?Key=='${TAG_KEY}'] | [0].Value" \
      --output text 2>/dev/null || true
  )"

  # Tag secret if needed or skip if tag exists
  if [[ "${existing_value}" == "None" || -z "${existing_value}" ]]; then
    echo "Tag missing on: ${arn}"
    echo " --> Adding tag ${TAG_KEY}=${TAG_VALUE}"
    aws secretsmanager tag-resource \
      --region "${REGION}" \
      --secret-id "${arn}" \
      --tags "Key=${TAG_KEY},Value=${TAG_VALUE}"
    UPDATED=$((UPDATED + 1))
  else
    echo "Tag exists on: ${arn} (Environment=${existing_value}) --> Skipping"
    SKIPPED=$((SKIPPED + 1))
  fi
done


echo "Done. Secrets Updated: ${UPDATED}, Secrets Skipped: ${SKIPPED}"

