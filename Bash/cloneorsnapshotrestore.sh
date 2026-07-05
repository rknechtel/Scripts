#!/bin/bash
# *********************************************************************
# Script: cloneorsnapshotrestore.sh
# Author: Richard Knechtel
# Date: 06/24/2026
# Description: Time-stamped runbook for creating a dev Aurora PostgreSQL
#              cluster from production via one of:
#                (A) Aurora fast clone (copy-on-write) - fastest, coupled to source
#                (B) Aurora full-copy clone           - standalone, slower (scales with size)
#                (C) Snapshot -> restore              - reusable artifact, cross-account/region
#              All operate at the storage layer, avoiding the slow
#              in-database "CREATE DATABASE ... TEMPLATE" copy.
#
# Requires: AWS CLI v2, configured credentials with RDS permissions.
# *********************************************************************

set -euo pipefail

# ----------------------- PARAMETERS ----------------------------------
# All passed in as positional arguments:
#   $1 METHOD         clone | full-copy | snapshot
#   $2 REGION         e.g. us-east-1
#   $3 SOURCE_CLUSTER source (prod) Aurora cluster identifier
#   $4 NEW_CLUSTER    new dev cluster identifier to create
#   $5 SUBNET_GROUP   DB subnet group for the new cluster
#   $6 SG_IDS         VPC security group id(s); space-separated, double quote if multiple
#   $7 MIN_ACU        Serverless v2 min capacity (ACU)
#   $8 MAX_ACU        Serverless v2 max capacity (ACU)
#   $9 ADD_READER     (OPTIONAL) true | false - add a reader instance too.
#                     Defaults to false (writer only).
#
# Example:
#   ./cloneorsnapshotrestore.sh clone us-east-1 mycompany-ap-prod mycompany-ap-dev-mycompany-ap-subnetgroup-dev "sg-0f1ef0bed67685483 sg-0189dea5c7fa38ba3" 0 64
#   ./cloneorsnapshotrestore.sh clone us-east-1 mycompany-ap-prod mycompany-ap-dev mycompany-ap-subnetgroup-dev "sg-0f1ef0bed67685483" 0 64 true
# ---------------------------------------------------------------------

METHOD="${1:-}"
REGION="${2:-}"
SOURCE_CLUSTER="${3:-}"
NEW_CLUSTER="${4:-}"
SUBNET_GROUP="${5:-}" # DB Subnet Group for the Restored Cluster (Must already exist)
SG_IDS="${6:-}"       # Security Groups for the Restored Cluster (Must already exist) (Double quotes and each group space delimeted)
MIN_ACU="${7:-}"
MAX_ACU="${8:-}"
ADD_READER="${9:-false}"   # OPTIONAL - true | false (defaults to false = writer only)

if [[ $# -lt 8 ]]; then
  echo "Usage: $0 <clone|full-copy|snapshot> <region> <source_cluster> <new_cluster> <subnet_group> <sg_ids> <min_acu> <max_acu> [add_reader:true|false]"
  exit 1
fi

# Derived / fixed values
NEW_WRITER="${NEW_CLUSTER}-0"               # writer instance
NEW_READER="${NEW_CLUSTER}-1"               # reader instance (created only if ADD_READER=true)
ENGINE="aurora-postgresql"
SNAPSHOT_ID="mycompany-prod-snap-$(date +%Y%m%d-%H%M%S)"   # only used when METHOD=snapshot
# ---------------------------------------------------------------------

ts() { date '+%Y-%m-%d %H:%M:%S'; }
echo "===== START ($(ts)) method=${METHOD} ====="
SECONDS=0

if [[ "$METHOD" == "clone" ]]; then
  # (A) FAST CLONE - copy-on-write. Near-instant; shares blocks with source
  # until written. Same account + region + VPC as the source cluster.
  echo "[$(ts)] Creating clone ${NEW_CLUSTER} from ${SOURCE_CLUSTER}..."
  aws rds restore-db-cluster-to-point-in-time \
    --region "$REGION" \
    --source-db-cluster-identifier "$SOURCE_CLUSTER" \
    --db-cluster-identifier "$NEW_CLUSTER" \
    --restore-type copy-on-write \
    --use-latest-restorable-time \
    --vpc-security-group-ids $SG_IDS \
    --db-subnet-group-name "$SUBNET_GROUP" \
    --serverless-v2-scaling-configuration "MinCapacity=${MIN_ACU},MaxCapacity=${MAX_ACU}"

elif [[ "$METHOD" == "full-copy" ]]; then
  # (B) FULL-COPY CLONE - physically copies the entire volume up front, so the
  # new cluster is fully standalone (no shared pages, no clone-count coupling).
  # Slower to become available and time scales with data size.
  echo "[$(ts)] Creating full-copy clone ${NEW_CLUSTER} from ${SOURCE_CLUSTER}..."
  aws rds restore-db-cluster-to-point-in-time \
    --region "$REGION" \
    --source-db-cluster-identifier "$SOURCE_CLUSTER" \
    --db-cluster-identifier "$NEW_CLUSTER" \
    --restore-type full-copy \
    --use-latest-restorable-time \
    --vpc-security-group-ids $SG_IDS \
    --db-subnet-group-name "$SUBNET_GROUP" \
    --serverless-v2-scaling-configuration "MinCapacity=${MIN_ACU},MaxCapacity=${MAX_ACU}"

elif [[ "$METHOD" == "snapshot" ]]; then
  # (C) SNAPSHOT -> RESTORE
  echo "[$(ts)] Creating cluster snapshot ${SNAPSHOT_ID} of ${SOURCE_CLUSTER}..."
  aws rds create-db-cluster-snapshot \
    --region "$REGION" \
    --db-cluster-snapshot-identifier "$SNAPSHOT_ID" \
    --db-cluster-identifier "$SOURCE_CLUSTER"

  echo "[$(ts)] Waiting for snapshot to be available..."
  aws rds wait db-cluster-snapshot-available \
    --region "$REGION" \
    --db-cluster-snapshot-identifier "$SNAPSHOT_ID"
  echo "[$(ts)] Snapshot ready (elapsed ${SECONDS}s)."

  echo "[$(ts)] Restoring ${NEW_CLUSTER} from snapshot..."
  aws rds restore-db-cluster-from-snapshot \
    --region "$REGION" \
    --db-cluster-identifier "$NEW_CLUSTER" \
    --snapshot-identifier "$SNAPSHOT_ID" \
    --engine "$ENGINE" \
    --vpc-security-group-ids $SG_IDS \
    --db-subnet-group-name "$SUBNET_GROUP" \
    --serverless-v2-scaling-configuration "MinCapacity=${MIN_ACU},MaxCapacity=${MAX_ACU}"
else
  echo "ERROR: METHOD must be 'clone', 'full-copy', or 'snapshot'."; exit 1
fi

# Both paths: wait for the cluster, then add a Serverless v2 writer instance.
echo "[$(ts)] Waiting for cluster ${NEW_CLUSTER} to be available..."
aws rds wait db-cluster-available --region "$REGION" --db-cluster-identifier "$NEW_CLUSTER"
echo "[$(ts)] Cluster available (elapsed ${SECONDS}s)."

echo "[$(ts)] Creating Serverless v2 writer instance ${NEW_WRITER}..."
aws rds create-db-instance \
  --region "$REGION" \
  --db-instance-identifier "$NEW_WRITER" \
  --db-cluster-identifier "$NEW_CLUSTER" \
  --engine "$ENGINE" \
  --db-instance-class db.serverless

echo "[$(ts)] Waiting for writer instance to be available..."
aws rds wait db-instance-available --region "$REGION" --db-instance-identifier "$NEW_WRITER"

# OPTIONAL: add a reader instance if ADD_READER=true.
# A second instance in an Aurora cluster automatically becomes a reader.
if [[ "$ADD_READER" == "true" ]]; then
  echo "[$(ts)] Creating Serverless v2 reader instance ${NEW_READER}..."
  aws rds create-db-instance \
    --region "$REGION" \
    --db-instance-identifier "$NEW_READER" \
    --db-cluster-identifier "$NEW_CLUSTER" \
    --engine "$ENGINE" \
    --db-instance-class db.serverless

  echo "[$(ts)] Waiting for reader instance to be available..."
  aws rds wait db-instance-available --region "$REGION" --db-instance-identifier "$NEW_READER"
else
  echo "[$(ts)] No reader instance requested (ADD_READER=${ADD_READER}) - skipping."
fi

# Show the new endpoints
ENDPOINT=$(aws rds describe-db-clusters --region "$REGION" --db-cluster-identifier "$NEW_CLUSTER" --query 'DBClusters[0].Endpoint' --output text)
READER_ENDPOINT=$(aws rds describe-db-clusters --region "$REGION" --db-cluster-identifier "$NEW_CLUSTER" --query 'DBClusters[0].ReaderEndpoint' --output text)

echo "===== DONE ($(ts)) total elapsed ${SECONDS}s ====="
echo "New writer endpoint: ${ENDPOINT}"
if [[ "$ADD_READER" == "true" ]]; then
  echo "New reader endpoint: ${READER_ENDPOINT}"
fi
echo
echo "Next steps inside the new cluster (the restored DB is named the same as prod, e.g. \"mycompany\"):"
echo "  -- make the 3 extra dev copies (run in parallel sessions for speed):"
echo "  --   CREATE DATABASE \"mycompany-dev1\" TEMPLATE \"mycompany\";"
echo "  --   CREATE DATABASE \"mycompany-dev2\" TEMPLATE \"mycompany\";"
echo "  --   CREATE DATABASE \"mycompany-dev3\" TEMPLATE \"mycompany\";"
echo "  -- then rename the original last:"
echo "  --   ALTER DATABASE \"mycompany\" RENAME TO \"mycompany-dev-4\";"
echo
echo "OR:"
echo "Create clones for each dev-* database as their own cluster."
echo "mycompany-ap-dev1, mycompany-ap-dev2, mycompany-ap-dev3, mycompany-ap-dev4"
