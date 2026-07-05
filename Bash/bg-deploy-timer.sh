#!/usr/bin/env bash
# *********************************************************************
# Script: bg-deploy-timer.sh
# Author: Richard Knechtel
# Date: 06/10/2026
# Description: Helpers for an Aurora PostgreSQL Blue/Green deployment lifecycle.
#
# Modes:
#   watch       - poll the deployment until Status=AVAILABLE, timing it precisely
#   measure     - retroactively estimate provisioning duration from green-resource events
#   check       - show the green cluster's engine version and Serverless v2 platform version
#   switchover  - run the switchover and poll until SWITCHOVER_COMPLETED (or rollback to AVAILABLE)
#   cleanup     - tear down a deployment. Auto-detects the scenario:
#                   * SWITCHOVER_COMPLETED -> delete record (no target) + delete old (-oldN) blue cluster
#                   * AVAILABLE / not switched -> delete record WITH --delete-target (removes green)
#                   * record already gone -> delete any orphaned green/-old clusters directly
#
# Usage:
#   ./bg-deploy-timer.sh watch      <bgd-id>
#   ./bg-deploy-timer.sh measure    <bgd-id>
#   ./bg-deploy-timer.sh check      [green-instance-id]
#   ./bg-deploy-timer.sh switchover <bgd-id> [timeout-seconds]     # default 600
#   CONFIRM=yes ./bg-deploy-timer.sh cleanup <bgd-id>              # DRY RUN unless CONFIRM=yes
#
# Notes:
#   - All RDS timestamps are UTC.
#   - "measure"/"check" only work PRE-switchover, while green resources carry the -green- suffix.
#   - CONFIRM=yes is an ENV VAR and must come BEFORE the command, not as a trailing argument.
#   - cleanup snapshots -old (real data) before deleting; green targets are deleted without snapshot.
#   - abort path clears deletion protection on the green target before --delete-target.
#   - Requires: awscli v2, bash, coreutils (date, sort).
#       AWS CLI
#         Install AWS CLI in Linux:
#         curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#         unzip awscliv2.zip
#         sudo ./aws/install
#
# *********************************************************************

set -euo pipefail

MODE="${1:-}"
BGID="${2:-}"
SWITCHOVER_TIMEOUT="${3:-600}"
POLL_INTERVAL="${POLL_INTERVAL:-30}"
MAX_EVENT_DURATION=20160
CONFIRM="${CONFIRM:-no}"

for a in "$@"; do
  [ "$a" = "CONFIRM=yes" ] && CONFIRM=yes
done

usage() {
  cat <<EOF
Usage:
  $0 watch      <bgd-id>               # poll until Status=AVAILABLE, timing it precisely
  $0 measure    <bgd-id>               # estimate provisioning duration from green-resource events
  $0 check      [green-instance-id]    # show green cluster engine + Serverless v2 platform version
  $0 switchover <bgd-id> [timeout]     # run switchover, poll to SWITCHOVER_COMPLETED (default 600s)
  CONFIRM=yes $0 cleanup <bgd-id>      # tear down deployment (auto-detects scenario)

Env:
  POLL_INTERVAL  seconds between polls in watch/switchover modes (default: 30)
  CONFIRM        set to "yes" to make cleanup actually delete (default: no = dry run)
                 NOTE: must be placed BEFORE the command.
EOF
  exit 1
}

[ -z "$MODE" ] && usage
case "$MODE" in
  watch|measure|switchover|cleanup) [ -z "$BGID" ] && usage ;;
esac

fmt_elapsed() {
  local start="$1" stop="$2" elapsed
  elapsed=$(( $(date -d "$stop" +%s) - $(date -d "$start" +%s) ))
  echo "Elapsed seconds: $elapsed"
  printf 'Elapsed time: %02dh %02dm %02ds\n' \
    $(( elapsed / 3600 )) $(( (elapsed % 3600) / 60 )) $(( elapsed % 60 ))
}

get_start() {
  aws rds describe-blue-green-deployments \
    --blue-green-deployment-identifier "$BGID" \
    --query 'BlueGreenDeployments[0].CreateTime' --output text
}

get_status() {
  aws rds describe-blue-green-deployments \
    --blue-green-deployment-identifier "$BGID" \
    --query 'BlueGreenDeployments[0].Status' --output text
}

# delete one cluster: $1=cluster-id, $2=snapshot|nosnapshot
delete_cluster() {
  local cl="$1" mode="$2" i snap
  echo "Disabling deletion protection on $cl ..."
  aws rds modify-db-cluster --db-cluster-identifier "$cl" \
    --no-deletion-protection --apply-immediately >/dev/null || true
  echo "Deleting instances in $cl ..."
  for i in $(aws rds describe-db-clusters --db-cluster-identifier "$cl" \
      --query 'DBClusters[0].DBClusterMembers[].DBInstanceIdentifier' --output text); do
    echo "  deleting instance $i"
    aws rds delete-db-instance --db-instance-identifier "$i" --skip-final-snapshot >/dev/null || true
  done
  if [ "$mode" = "snapshot" ]; then
    snap="${cl}-final-$(date +%Y%m%d-%H%M%S)"
    echo "Deleting cluster $cl with final snapshot $snap ..."
    aws rds delete-db-cluster --db-cluster-identifier "$cl" \
      --final-db-snapshot-identifier "$snap" \
      --query 'DBCluster.Status' --output text || true
  else
    echo "Deleting cluster $cl (no final snapshot) ..."
    aws rds delete-db-cluster --db-cluster-identifier "$cl" \
      --skip-final-snapshot --query 'DBCluster.Status' --output text || true
  fi
}

watch_mode() {
  local start status now
  start=$(get_start)
  echo "Blue/Green Deployment: $BGID"
  echo "Start:  $start"
  echo "Polling every ${POLL_INTERVAL}s until Status=AVAILABLE ..."
  echo
  while true; do
    status=$(get_status)
    now=$(date -u +%Y-%m-%dT%H:%M:%S+00:00)
    echo "[$now] Status: $status"
    case "$status" in
      AVAILABLE)
        echo; echo "Stop:   $now  (moment AVAILABLE was observed)"
        fmt_elapsed "$start" "$now"; return 0 ;;
      INVALID_CONFIGURATION|SOURCE_PREPARING_FAILED|FAILED)
        echo; echo "Deployment ended in failure state: $status"; return 1 ;;
    esac
    sleep "$POLL_INTERVAL"
  done
}

measure_mode() {
  local start green_cluster green_instances stop
  start=$(get_start)
  green_cluster=$(aws rds describe-db-clusters \
    --query "DBClusters[?contains(DBClusterIdentifier,'green')].DBClusterIdentifier | [0]" \
    --output text)
  if [ -z "$green_cluster" ] || [ "$green_cluster" = "None" ]; then
    echo "No green cluster found (already switched over, or not provisioned)." >&2; exit 1
  fi
  green_instances=$(aws rds describe-db-clusters --db-cluster-identifier "$green_cluster" \
    --query 'DBClusters[0].DBClusterMembers[].DBInstanceIdentifier' --output text)
  stop=$( {
    aws rds describe-events --source-identifier "$green_cluster" --source-type db-cluster \
      --duration "$MAX_EVENT_DURATION" --query 'Events[].Date' --output text | tr '\t' '\n'
    for i in $green_instances; do
      aws rds describe-events --source-identifier "$i" --source-type db-instance \
        --duration "$MAX_EVENT_DURATION" --query 'Events[].Date' --output text | tr '\t' '\n'
    done
  } | grep -v '^$' | sort | tail -1 )
  echo "Blue/Green Deployment: $BGID"
  echo "Green cluster:         $green_cluster"
  echo "Start: $start"
  echo "Stop:  $stop  (latest green-resource event; approximate)"
  if [ -z "$stop" ] || [ "$stop" = "None" ]; then echo "Could not determine a stop time." >&2; exit 1; fi
  fmt_elapsed "$start" "$stop"
}

check_mode() {
  local green_instance="$BGID" cid ev_pv engine_version platform_version
  if [ -z "$green_instance" ] || [ "$green_instance" = "None" ] || [ "$green_instance" = "CONFIRM=yes" ]; then
    green_instance=$(aws rds describe-db-instances \
      --query "DBInstances[?contains(DBInstanceIdentifier,'green')].DBInstanceIdentifier | [0]" \
      --output text)
  fi
  if [ -z "$green_instance" ] || [ "$green_instance" = "None" ]; then
    echo "No green DB instance found." >&2
    echo "Pass the instance id explicitly: $0 check <green-instance-id>" >&2; exit 1
  fi
  cid=$(aws rds describe-db-instances --db-instance-identifier "$green_instance" \
    --query 'DBInstances[0].DBClusterIdentifier' --output text)
  ev_pv=$(aws rds describe-db-clusters --db-cluster-identifier "$cid" \
    --query 'DBClusters[0].[EngineVersion,ServerlessV2PlatformVersion]' --output text)
  engine_version=$(echo "$ev_pv" | awk '{print $1}')
  platform_version=$(echo "$ev_pv" | awk '{print $2}')
  echo "Upgraded Cluster at: $cid"
  echo "Green Instance: $green_instance"
  echo "Engine Version: $engine_version"
  echo "Serverless V2 Platform Version: $platform_version"
}

switchover_mode() {
  local start status now
  start=$(date -u +%Y-%m-%dT%H:%M:%S+00:00)
  echo "Blue/Green Deployment: $BGID"
  echo "Initiating switchover (timeout ${SWITCHOVER_TIMEOUT}s) at $start ..."
  aws rds switchover-blue-green-deployment \
    --blue-green-deployment-identifier "$BGID" \
    --switchover-timeout "$SWITCHOVER_TIMEOUT" \
    --query 'BlueGreenDeployment.Status' --output text
  echo "Polling every ${POLL_INTERVAL}s ..."; echo
  while true; do
    status=$(get_status)
    now=$(date -u +%Y-%m-%dT%H:%M:%S+00:00)
    echo "[$now] Status: $status"
    case "$status" in
      SWITCHOVER_COMPLETED)
        echo; echo "Switchover completed. Green is live on the original endpoints; old blue renamed -oldN."
        fmt_elapsed "$start" "$now"
        echo "Validate your app, then: CONFIRM=yes $0 cleanup $BGID"; return 0 ;;
      AVAILABLE)
        echo; echo "Status returned to AVAILABLE -> switchover did NOT complete (timed out or cancelled)."
        echo "Common causes: replication lag, long-running transactions, or DDL/large-object changes."
        echo "If it keeps cancelling, the green is diverged; tear it down: CONFIRM=yes $0 cleanup $BGID"
        return 1 ;;
      SWITCHOVER_FAILED|INVALID_CONFIGURATION)
        echo; echo "Switchover ended in failure state: $status"; return 1 ;;
    esac
    sleep "$POLL_INTERVAL"
  done
}

cleanup_mode() {
  local status scenario old_clusters green_clusters c
  status=$(get_status 2>/dev/null || true)
  echo "Deployment $BGID status: ${status:-<not found>}"

  if [ "$status" = "SWITCHOVER_COMPLETED" ]; then
    scenario=post
  elif [ -n "$status" ] && [ "$status" != "None" ]; then
    scenario=abort
  else
    scenario=record-gone
  fi

  old_clusters=$(aws rds describe-db-clusters \
    --query "DBClusters[?contains(DBClusterIdentifier,'-old')].DBClusterIdentifier" --output text)
  green_clusters=$(aws rds describe-db-clusters \
    --query "DBClusters[?contains(DBClusterIdentifier,'green')].DBClusterIdentifier" --output text)

  echo
  echo "Scenario: $scenario"
  echo "Planned actions:"
  case "$scenario" in
    post)
      echo "  - delete deployment record $BGID (WITHOUT --delete-target)"
      echo "  - delete old blue cluster(s), final snapshot first: ${old_clusters:-<none>}" ;;
    abort)
      echo "  - clear deletion protection on green target(s), then"
      echo "  - delete deployment record $BGID WITH --delete-target (tears down green)"
      echo "    green target(s): ${green_clusters:-<none>}" ;;
    record-gone)
      echo "  - deployment record already gone"
      echo "  - delete orphaned green cluster(s) (no snapshot): ${green_clusters:-<none>}"
      echo "  - delete orphaned old cluster(s) (snapshot first): ${old_clusters:-<none>}" ;;
  esac

  if [ "$CONFIRM" != "yes" ]; then
    echo; echo "DRY RUN. Re-run with CONFIRM=yes BEFORE the command:"
    echo "  CONFIRM=yes $0 cleanup $BGID"
    return 0
  fi

  echo
  case "$scenario" in
    post)
      echo "Deleting deployment record $BGID ..."
      aws rds delete-blue-green-deployment \
        --blue-green-deployment-identifier "$BGID" \
        --query 'BlueGreenDeployment.Status' --output text || true
      for c in $old_clusters; do echo; delete_cluster "$c" snapshot; done ;;
    abort)
      for c in $green_clusters; do
        echo "Disabling deletion protection on green target $c ..."
        aws rds modify-db-cluster --db-cluster-identifier "$c" \
          --no-deletion-protection --apply-immediately >/dev/null || true
      done
      echo "Deleting deployment record $BGID WITH --delete-target ..."
      if aws rds delete-blue-green-deployment \
           --blue-green-deployment-identifier "$BGID" --delete-target \
           --query 'BlueGreenDeployment.Status' --output text; then
        echo "Green environment teardown initiated via --delete-target."
      else
        echo "delete-target failed (see error above)." >&2
        echo "Fallback: delete the record alone, then rerun cleanup (record-gone path):" >&2
        echo "  aws rds delete-blue-green-deployment --blue-green-deployment-identifier $BGID" >&2
        echo "  CONFIRM=yes $0 cleanup $BGID" >&2
      fi ;;
    record-gone)
      for c in $green_clusters; do echo; delete_cluster "$c" nosnapshot; done
      for c in $old_clusters;   do echo; delete_cluster "$c" snapshot;   done ;;
  esac

  echo
  echo "Submitted. Verify with:"
  echo "  aws rds describe-db-clusters --query \"DBClusters[].[DBClusterIdentifier,EngineVersion,Status]\" --output table"
}

case "$MODE" in
  watch)      watch_mode ;;
  measure)    measure_mode ;;
  check)      check_mode ;;
  switchover) switchover_mode ;;
  cleanup)    cleanup_mode ;;
  *)          usage ;;
esac
