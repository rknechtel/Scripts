#!/usr/bin/env bash
# *********************************************************************
# Script: auditsecrets.sh 
# Author: Richard Knechtel
# Date: 06/25/2026
# Description: inventory every AWS Secrets Manager secret and write a CSV
# with size + the other decision-tree inputs (rotation, replicas), so each
# secret is pre-classified for migration to Parameter Store.
#
# Retrieval mode is selectable:
#   --mode batch   uses batch-get-secret-value (up to 20 secrets per call) — faster, fewer API calls   [default]
#   --mode single  uses get-secret-value (one call per secret) — simpler, easier to debug / throttle-friendly
#
# Requires: AWS CLI v2 + jq, with credentials allowing
#   secretsmanager:ListSecrets, GetSecretValue, BatchGetSecretValue, DescribeSecret
# Works on bash 3.2+ (no associative arrays), so it runs on stock macOS bash too.
#
# Usage:
#   ./auditsecrets.sh                              # batch mode, AWS_REGION or us-east-1
#   ./auditsecrets.sh --mode single                # one secret at a time
#   ./auditsecrets.sh --mode batch us-east-1 eu-west-1
#   ./auditsecrets.sh --no-replicas us-east-1      # skip replica lookup (faster; see note)
#
# Output: secret_sizes.csv in the current directory.
# NOTE:
# This decrypts every secret value (required to measure size) and will
# appear in CloudTrail. Run it from a host you trust.
# *********************************************************************

set -euo pipefail

MODE="batch"
CHECK_REPLICAS=1
OUT="secret_sizes.csv"
BATCH_SIZE=20
REGIONS=()

# ---- parse args ----
while [ $# -gt 0 ]; do
  case "$1" in
    -m|--mode)     MODE="${2:-}"; shift 2 ;;
    --mode=*)      MODE="${1#*=}"; shift ;;
    --no-replicas) CHECK_REPLICAS=0; shift ;;
    -o|--out)      OUT="${2:-}"; shift 2 ;;
    -h|--help)     grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)            echo "Unknown option: $1" >&2; exit 1 ;;
    *)             REGIONS+=("$1"); shift ;;
  esac
done

case "$MODE" in batch|single) ;; *) echo "ERROR: --mode must be 'batch' or 'single'" >&2; exit 1 ;; esac
[ ${#REGIONS[@]} -eq 0 ] && REGIONS=("${AWS_REGION:-us-east-1}")

command -v aws >/dev/null || { echo "ERROR: AWS CLI not found" >&2; exit 1; }
command -v jq  >/dev/null || { echo "ERROR: jq not found" >&2; exit 1; }

# byte length of a secret's value (SecretString + decoded SecretBinary) from a JSON object
SIZE_JQ='((.SecretString // "") | length) + ((.SecretBinary // "") | @base64d? // "" | length)'

# ---- helpers ----
replicas_for() {  # $1=region $2=arn  -> ";"-joined regions, or "none" / "not-checked"
  if [ "$CHECK_REPLICAS" -eq 0 ]; then echo "not-checked"; return; fi
  local r
  r=$(aws secretsmanager describe-secret --region "$1" --secret-id "$2" \
        --query 'ReplicationStatus[].Region' --output text 2>/dev/null | tr '\t' ';')
  [ -z "$r" ] && r="none"
  echo "$r"
}

emit_row() {  # $1=region $2=name $3=bytes $4=rotation $5=replicas
  local region="$1" name="$2" bytes="$3" rot="$4" reps="$5" tier target safe
  if   [ "$bytes" -le 4096 ]; then tier="<=4KB (Standard)"
  elif [ "$bytes" -le 8192 ]; then tier="4-8KB (Advanced)"
  else                             tier=">8KB"
  fi
  if [ "$rot" = "True" ] || [ "$bytes" -gt 8192 ] || { [ "$reps" != "none" ] && [ "$reps" != "not-checked" ]; }; then
    target="Secrets Manager"
  elif [ "$bytes" -gt 4096 ]; then
    target="Parameter Store - Advanced"
  else
    target="Parameter Store - Standard (free)"
  fi
  safe=$(printf '%s' "$name" | sed 's/"/""/g')   # CSV-escape embedded quotes
  printf '%s,"%s",%s,%s,%s,%s,%s\n' \
    "$region" "$safe" "$bytes" "$tier" "$rot" "$reps" "$target" >> "$OUT"
}

# ---- main ----
echo "region,name,bytes,size_tier,rotation_enabled,replica_regions,recommended_target" > "$OUT"
echo "Mode: $MODE | replica check: $([ "$CHECK_REPLICAS" -eq 1 ] && echo on || echo off)" >&2

START_EPOCH=$(date +%s)
START_TS=$(date '+%Y-%m-%d %H:%M:%S %Z')
echo "Start time: $START_TS" >&2

total=0
for REGION in "${REGIONS[@]}"; do
  echo "Scanning region: $REGION ..." >&2
  NEXT=""
  CHUNK=()   # holds "arn<TAB>name<TAB>rotation" lines for batch mode

  flush_chunk() {  # process whatever is in CHUNK (batch mode)
    [ ${#CHUNK[@]} -eq 0 ] && return
    local arns=() line arn name rot bytes reps batchtsv
    for line in "${CHUNK[@]}"; do arns+=("$(printf '%s' "$line" | cut -f1)"); done
    batchtsv=$(aws secretsmanager batch-get-secret-value --region "$REGION" \
                 --secret-id-list "${arns[@]}" --output json \
               | jq -r ".SecretValues[] | [.ARN, ($SIZE_JQ)] | @tsv")
    for line in "${CHUNK[@]}"; do
      arn=$(printf '%s' "$line" | cut -f1)
      name=$(printf '%s' "$line" | cut -f2)
      rot=$(printf '%s' "$line" | cut -f3)
      bytes=$(printf '%s\n' "$batchtsv" | awk -F'\t' -v a="$arn" '$1==a{print $2; exit}')
      [ -z "$bytes" ] && bytes=0   # value not returned (e.g. access error)
      reps=$(replicas_for "$REGION" "$arn")
      emit_row "$REGION" "$name" "$bytes" "$rot" "$reps"
      total=$((total+1))
    done
    CHUNK=()
  }

  while : ; do
    PAGE=$(aws secretsmanager list-secrets --region "$REGION" --max-results 100 \
           ${NEXT:+--next-token "$NEXT"} --output json)

    while IFS=$'\t' read -r ARN NAME ROT; do
      [ -z "$ARN" ] && continue
      if [ "$MODE" = "single" ]; then
        BYTES=$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "$ARN" \
                  --output json | jq -r "$SIZE_JQ")
        REPS=$(replicas_for "$REGION" "$ARN")
        emit_row "$REGION" "$NAME" "$BYTES" "$ROT" "$REPS"
        total=$((total+1))
      else
        CHUNK+=("$(printf '%s\t%s\t%s' "$ARN" "$NAME" "$ROT")")
        [ ${#CHUNK[@]} -ge "$BATCH_SIZE" ] && flush_chunk
      fi
    done < <(echo "$PAGE" | jq -r '.SecretList[] | [.ARN, .Name, (.RotationEnabled // false | tostring | (.[0:1]|ascii_upcase)+.[1:])] | @tsv')

    NEXT=$(echo "$PAGE" | jq -r '.NextToken // empty')
    [ -z "$NEXT" ] && break
  done
  flush_chunk   # any remainder (< BATCH_SIZE) in batch mode
done

echo "Done. $total secrets written to $OUT" >&2
echo "" >&2
echo "Summary by recommended target:" >&2
tail -n +2 "$OUT" | awk -F, '{print $NF}' | sort | uniq -c | sort -rn >&2

END_EPOCH=$(date +%s)
END_TS=$(date '+%Y-%m-%d %H:%M:%S %Z')
ELAPSED=$(( END_EPOCH - START_EPOCH ))
echo "" >&2
echo "Start time: $START_TS" >&2
echo "End time:   $END_TS" >&2
printf "Elapsed:    %dm %ds\n" $((ELAPSED/60)) $((ELAPSED%60)) >&2
