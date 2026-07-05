#!/bin/bash
# *********************************************************************
# Script: showpods.sh
# Author: Richard Knechtel
# Date: 06/10/2022
# Description: This will let you shows pods in namespaces.
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
# source showpods.sh <NAMESPACE>(Optional)
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo

NAMESPACE=$1

pod_dump_csv=$(kubectl get pods -A -o=jsonpath="{range .items[*]}{.metadata.namespace},{.metadata.name}{'\n'}{end}")

IFS=$'\n'
for line in $pod_dump_csv; do

  pod_namespace=$(echo $line | awk -F, {'print $1'})
  pod_name=$(echo $line | awk -F, {'print $2'})
  
    if [ $# -eq 0 ]  && [ -z "${NAMESPACE}" ]; then
	  pod_namespace=$(echo $line | awk -F, {'print $1'})
	else
	  if [[ "$NAMESPACE" == "$pod_namespace" ]]; then
	    pod_namespace=$NAMESPACE
	  else
		continue
	  fi
	fi
	
  kubectl get pod $pod_name --namespace $pod_namespace
done
