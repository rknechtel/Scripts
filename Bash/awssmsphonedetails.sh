#!/bin/bash
# *********************************************************************
# Script: awssmsphonedetails.sh
# Author: Richard Knechtel
# Date: 03/27/2026
# Description: 
# Fetches all details for an AWS End User Messaging SMS phone number,
# including all associated registrations and their field values.
#
# Parameters: MFA Token Code
# Note: This comes from:
#  Keepass --> <Key Name> --> KeeOtp2 --> Copy TOTP
#  OR
#  1Password --> One Time Pasword --> Copy (copies code)
#
# Note: You must have active AWS Access keys for this to work and MFA enabled and setup.
#
# Note: You MUST have mfa_serial set in your .aws/config file.
# Example:
# [default]
# region = us-east-1
# output = json
# mfa_serial=arn:aws:iam::123456789012:mfa/MyMFADevice
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
# Usage: ./awssmsphonedetails.sh <phone-number-id> [--profile <aws-profile>] [--region <aws-region>]
# Example: ./awssmsphonedetails.sh phone-cc616930e0aa4a1fbcc1830cd60521ac
#
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
#echo Parameters Passed = $1
#echo


set -euo pipefail

# --- Helpers -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <phone-number-id> [--profile <aws-profile>] [--region <aws-region>]"
  echo "  phone-number-id   The AWS phone number ID (e.g. phone-cc616930e0aa4a1fbcc1830cd60521ac)"
  echo "  --profile         (optional) AWS CLI profile name"
  echo "  --region          (optional) AWS region (e.g. us-east-1)"
  exit 1
}

print_header() {
  local title="$1"
  local len=${#title}
  local border
  border=$(printf '═%.0s' $(seq 1 $((len + 4))))
  echo ""
  echo "╔${border}╗"
  echo "║  ${title}  ║"
  echo "╚${border}╝"
}

print_section() {
  echo ""
  echo "  ┌─ $1"
}

print_field() {
  local label="$1"
  local value="$2"
  if [[ -n "$value" && "$value" != "null" ]]; then
    printf "  │  %-35s %s\n" "$label:" "$value"
  fi
}

print_end_section() {
  echo "  └─────────────────────────────────────────────"
}

format_timestamp() {
  local ts="$1"
  if [[ -n "$ts" && "$ts" != "null" ]]; then
    date -d "@${ts}" '+%Y-%m-%d %H:%M:%S UTC' 2>/dev/null || \
    date -r "${ts}" '+%Y-%m-%d %H:%M:%S UTC' 2>/dev/null || \
    echo "$ts"
  fi
}

bool_display() {
  [[ "$1" == "true" ]] && echo "Yes" || echo "No"
}

# --- Argument parsing --------------------------------------------------------

PHONE_NUMBER_ID=""
CLI_PROFILE=""
CLI_REGION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      CLI_PROFILE="$2"; shift 2 ;;
    --region)
      CLI_REGION="$2"; shift 2 ;;
    --help|-h)
      usage ;;
    -*)
      echo "Unknown option: $1"; usage ;;
    *)
      if [[ -z "$PHONE_NUMBER_ID" ]]; then
        PHONE_NUMBER_ID="$1"; shift
      else
        echo "Unexpected argument: $1"; usage
      fi
      ;;
  esac
done

if [[ -z "$PHONE_NUMBER_ID" ]]; then
  echo "Error: phone-number-id is required."
  usage
fi

# Build the base AWS CLI command with optional profile/region
AWS_CMD="aws pinpoint-sms-voice-v2"
[[ -n "$CLI_PROFILE" ]] && AWS_CMD="$AWS_CMD --profile $CLI_PROFILE"
[[ -n "$CLI_REGION" ]] && AWS_CMD="$AWS_CMD --region $CLI_REGION"

# --- Check dependencies ------------------------------------------------------

for dep in aws jq; do
  if ! command -v "$dep" &>/dev/null; then
    echo "Error: '$dep' is required but not installed."
    exit 1
  fi
done

# =============================================================================
# STEP 1: Phone Number Details
# =============================================================================

print_header "PHONE NUMBER DETAILS"

PHONE_DETAILS=$($AWS_CMD describe-phone-numbers \
  --phone-number-ids "$PHONE_NUMBER_ID" \
  --output json 2>&1) || {
  echo "Error fetching phone number details:"
  echo "$PHONE_DETAILS"
  exit 1
}

PH=$(echo "$PHONE_DETAILS" | jq '.PhoneNumbers[0]')

print_section "Identity"
print_field "Phone Number ID"     "$(echo "$PH" | jq -r '.PhoneNumberId')"
print_field "Phone Number ARN"    "$(echo "$PH" | jq -r '.PhoneNumberArn')"
print_field "Phone Number"        "$(echo "$PH" | jq -r '.PhoneNumber')"
print_field "Status"              "$(echo "$PH" | jq -r '.Status')"
print_field "Country Code"        "$(echo "$PH" | jq -r '.IsoCountryCode')"
print_end_section

print_section "Configuration"
print_field "Number Type"         "$(echo "$PH" | jq -r '.NumberType')"
print_field "Message Type"        "$(echo "$PH" | jq -r '.MessageType')"
print_field "Capabilities"        "$(echo "$PH" | jq -r '.NumberCapabilities | join(", ")')"
print_field "Monthly Lease Price" "\$$(echo "$PH" | jq -r '.MonthlyLeasingPrice') USD"
print_field "Deletion Protection" "$(bool_display "$(echo "$PH" | jq -r '.DeletionProtectionEnabled')")"
print_end_section

print_section "Two-Way Messaging"
print_field "Two-Way Enabled"     "$(bool_display "$(echo "$PH" | jq -r '.TwoWayEnabled')")"
print_field "Two-Way Channel ARN" "$(echo "$PH" | jq -r '.TwoWayChannelArn // "N/A"')"
print_field "Self-Managed Opt-Outs" "$(bool_display "$(echo "$PH" | jq -r '.SelfManagedOptOutsEnabled')")"
print_end_section

print_section "Associations"
print_field "Opt-Out List"        "$(echo "$PH" | jq -r '.OptOutListName')"
print_field "Pool ID"             "$(echo "$PH" | jq -r '.PoolId // "N/A"')"
print_field "Registration ID"     "$(echo "$PH" | jq -r '.RegistrationId // "None"')"
print_end_section

print_section "Timestamps"
print_field "Created"             "$(format_timestamp "$(echo "$PH" | jq -r '.CreatedTimestamp')")"
print_end_section

# Extract the registration ID
REGISTRATION_ID=$(echo "$PH" | jq -r '.RegistrationId // empty')

if [[ -z "$REGISTRATION_ID" ]]; then
  echo ""
  echo "  ℹ  No registration is associated with this phone number."
  echo ""
  exit 0
fi

# =============================================================================
# STEP 2: Registration Associations
# =============================================================================

print_header "REGISTRATION ASSOCIATIONS"

ASSOCIATIONS=$($AWS_CMD list-registration-associations \
  --registration-id "$REGISTRATION_ID" \
  --output json 2>&1) || {
  echo "Error fetching registration associations:"
  echo "$ASSOCIATIONS"
  exit 1
}

ASSOC_COUNT=$(echo "$ASSOCIATIONS" | jq '.RegistrationAssociations | length')
echo ""
echo "  Total Associations: $ASSOC_COUNT"

echo "$ASSOCIATIONS" | jq -c '.RegistrationAssociations[]' | while read -r assoc; do
  print_section "Association"
  print_field "Resource ID"       "$(echo "$assoc" | jq -r '.ResourceId')"
  print_field "Resource Type"     "$(echo "$assoc" | jq -r '.ResourceType')"
  print_field "ISO Country Code"  "$(echo "$assoc" | jq -r '.IsoCountryCode // "N/A"')"
  print_field "Phone Number"      "$(echo "$assoc" | jq -r '.PhoneNumber // "N/A"')"
  print_end_section
done

# =============================================================================
# STEP 3: Registration Details
# =============================================================================

print_header "REGISTRATION DETAILS"

REG_DETAILS=$($AWS_CMD describe-registrations \
  --registration-ids "$REGISTRATION_ID" \
  --output json 2>&1) || {
  echo "Error fetching registration details:"
  echo "$REG_DETAILS"
  exit 1
}

RD=$(echo "$REG_DETAILS" | jq '.Registrations[0]')

print_section "Identity"
print_field "Registration ID"     "$(echo "$RD" | jq -r '.RegistrationId')"
print_field "Registration ARN"    "$(echo "$RD" | jq -r '.RegistrationArn')"
print_field "Registration Type"   "$(echo "$RD" | jq -r '.RegistrationType')"
print_field "Status"              "$(echo "$RD" | jq -r '.RegistrationStatus')"
print_end_section

print_section "Version Info"
print_field "Current Version"     "$(echo "$RD" | jq -r '.CurrentVersionNumber')"
print_field "Approved Version"    "$(echo "$RD" | jq -r '.ApprovedVersionNumber // "N/A"')"
print_field "Latest Denied Version" "$(echo "$RD" | jq -r '.LatestDeniedVersionNumber // "N/A"')"
print_field "Association Behavior" "$(echo "$RD" | jq -r '.AdditionalAttributes.AssociationBehavior // "N/A"')"
print_end_section

print_section "Timestamps"
print_field "Created"             "$(format_timestamp "$(echo "$RD" | jq -r '.CreatedTimestamp')")"
print_end_section

# =============================================================================
# STEP 4: Registration Field Values
# =============================================================================

print_header "REGISTRATION FIELD VALUES"

FIELD_VALUES=$($AWS_CMD describe-registration-field-values \
  --registration-id "$REGISTRATION_ID" \
  --output json 2>&1) || {
  echo "Error fetching registration field values:"
  echo "$FIELD_VALUES"
  exit 1
}

FIELD_COUNT=$(echo "$FIELD_VALUES" | jq '.RegistrationFieldValues | length')
echo ""
echo "  Total Fields: $FIELD_COUNT"

echo "$FIELD_VALUES" | jq -c '.RegistrationFieldValues[]' | while read -r field; do
  FIELD_PATH=$(echo "$field" | jq -r '.FieldPath')
  TEXT_VAL=$(echo "$field" | jq -r '.TextValue // empty')
  SELECT_VAL=$(echo "$field" | jq -r '.SelectChoices // empty | if type == "array" then join(", ") else . end')
  ATTACH_VAL=$(echo "$field" | jq -r '.RegistrationAttachmentId // empty')

  print_section "$FIELD_PATH"
  [[ -n "$TEXT_VAL" ]]   && print_field "Value"         "$TEXT_VAL"
  [[ -n "$SELECT_VAL" ]] && print_field "Selection"     "$SELECT_VAL"
  [[ -n "$ATTACH_VAL" ]] && print_field "Attachment ID" "$ATTACH_VAL"
  print_end_section
done

# =============================================================================
# STEP 5: Registration Versions
# =============================================================================

print_header "REGISTRATION VERSION HISTORY"

REG_VERSIONS=$($AWS_CMD describe-registration-versions \
  --registration-id "$REGISTRATION_ID" \
  --output json 2>&1) || {
  echo "Error fetching registration versions:"
  echo "$REG_VERSIONS"
  exit 1
}

echo "$REG_VERSIONS" | jq -c '.RegistrationVersions[]' | while read -r ver; do
  VER_NUM=$(echo "$ver" | jq -r '.VersionNumber')
  print_section "Version $VER_NUM"
  print_field "Status"            "$(echo "$ver" | jq -r '.RegistrationVersionStatus')"
  print_field "Created"          "$(format_timestamp "$(echo "$ver" | jq -r '.CreatedTimestamp')")"

  # Print any denial reasons
  DENIED_COUNT=$(echo "$ver" | jq '.DeniedReasons | length')
  if [[ "$DENIED_COUNT" -gt 0 ]]; then
    echo "  │"
    echo "  │  Denial Reasons:"
    echo "$ver" | jq -c '.DeniedReasons[]' | while read -r reason; do
      echo "  │    • $(echo "$reason" | jq -r '.Reason')"
      echo "  │      $(echo "$reason" | jq -r '.ShortDescription // ""')"
    done
  fi
  print_end_section
done

# =============================================================================
# Summary
# =============================================================================

print_header "SUMMARY"
echo ""
REG_TYPE=$(echo "$RD" | jq -r '.RegistrationType')
REG_STATUS=$(echo "$RD" | jq -r '.RegistrationStatus')
echo "  Phone Number    : $(echo "$PH" | jq -r '.PhoneNumber')"
echo "  Phone Number ID : $PHONE_NUMBER_ID"
echo "  Registration ID : $REGISTRATION_ID"
echo "  Type            : $REG_TYPE"
echo "  Status          : $REG_STATUS"
echo ""