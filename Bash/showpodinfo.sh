#!/bin/bash
# *********************************************************************
# Script: showpodinfo.sh
# Author: Richard Knechtel
# Date: 06/10/2022
# Description: This will let you shows pod info in namespaces.
#
# Parameters: Namespace
#
# Note: Requires program: jq
#       sudo apt-get install -y jq
#
#      Requires program: kubectl
#
# Immportant: These work in Bash - they have issues in ZShell.
#
# Example Call (bash)
# source showpodinfo.sh <NAMESPACE>(Optional)
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo

NAMESPACE=$1

pod_dump_csv=$(kubectl get pods -A -o=jsonpath="{range .items[*]}{.metadata.namespace},{.metadata.name}, {.spec.nodeName},{.status.phase}{'\n'}{end}")

PODNAMEPACE='Pod_Namespace'
PODNAME='Pod_Name'
PODNODE='Pod_Node'
PODSTATUS='Pod_Status'

pod_columns=$(echo $PODNAMEPACE $PODNAME $PODNODE $PODSTATUS)
echo $pod_columns | awk '{printf("%-16s %-40s %-41s %-10s\n", $1, $2, $3, $4);}'

IFS=$'\n'
for line in $pod_dump_csv; do

  pod_namespace=$(echo $line | awk -F, {'print $1'})
  pod_name=$(echo $line | awk -F, {'print $2'})
  pod_node=$(echo $line | awk -F, {'print $3'})
  pod_status=$(echo $line | awk -F, {'print $4'})
  
    if [ $# -eq 0 ]  && [ -z "${NAMESPACE}" ]; then
	  pod_namespace=$(echo $line | awk -F, {'print $1'})
	else
	  if [[ "$NAMESPACE" == "$pod_namespace" ]]; then
	    pod_namespace=$NAMESPACE
	  else
		continue
	  fi
	fi
	

  pod_column_values=$(echo $pod_namespace $pod_name $pod_node $pod_status)
  echo $pod_column_values | awk '{printf("%-16s %-40s %-41s %-10s\n", $1, $2, $3, $4);}'


done
