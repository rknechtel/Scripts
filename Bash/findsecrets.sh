#!/usr/bin/env bash
# *********************************************************************
# Script: findsecrets.sh
# Author: Richard Knechtel
# Date: 06/24/2026
# Description: Search AWS Secrets Manager for secrets matching a search term.
#
# Requires: AWS CLI v2, configured credentials with Secrets Manager permissions.
#
# Usage:
#   ./findsecrets.sh <search-term> [mode] [region]
#
#   <search-term>  Required. Text to search for (e.g. mycompany-dev-ap-ro).
#   [mode]         Optional. One of:
#                    prefix   - match secrets whose NAME starts with the term (server-side, fast). Default.
#                    contains - match secrets whose NAME contains the term anywhere (client-side).
#                    value    - match secrets whose VALUE contains the term (retrieves each secret).
#   [region]       Optional. AWS region. Defaults to your configured default.
#
# Examples:
#   ./findsecrets.sh mycompany-dev-ap-ro
#   ./findsecrets.sh mycompany-dev-ap-ro contains
#   ./findsecrets.sh mycompany-dev-ap-ro value us-east-1
# *********************************************************************

set -euo pipefail

SEARCH_TERM="${1:-}"
MODE="${2:-prefix}"
REGION="${3:-}"

if [[ -z "$SEARCH_TERM" ]]; then
  echo "Error: a search term is required." >&2
  echo "Usage: $0 <search-term> [prefix|contains|value] [region]" >&2
  exit 1
fi

# Build optional --region argument.
REGION_ARG=()
if [[ -n "$REGION" ]]; then
  REGION_ARG=(--region "$REGION")
fi

case "$MODE" in
  prefix)
    aws secretsmanager list-secrets \
      "${REGION_ARG[@]}" \
      --filters Key=name,Values="$SEARCH_TERM" \
      --query "SecretList[].{Name:Name,ARN:ARN}" \
      --output table
    ;;

  contains)
    aws secretsmanager list-secrets \
      "${REGION_ARG[@]}" \
      --query "SecretList[?contains(Name, '$SEARCH_TERM')].{Name:Name,ARN:ARN}" \
      --output table
    ;;

  value)
    aws secretsmanager list-secrets "${REGION_ARG[@]}" \
      --query "SecretList[].[Name,ARN]" --output text \
      | while IFS=$'\t' read -r name arn; do
          if aws secretsmanager get-secret-value "${REGION_ARG[@]}" \
               --secret-id "$arn" --query SecretString --output text 2>/dev/null \
               | grep -q "$SEARCH_TERM"; then
            printf '%s\t%s\n' "$name" "$arn"
          fi
        done
    ;;

  *)
    echo "Error: unknown mode '$MODE'. Use prefix, contains, or value." >&2
    exit 1
    ;;
esac
