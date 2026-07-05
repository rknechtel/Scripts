#!/bin/bash
# *********************************************************************
# Script: deletepods.sh
# Author: Richard Knechtel
# Date: 06/10/2022
# Description: This will let you delete pods in namespaces.
#
# Parameters: Namespace
#
# Note: Requires program: jq
#       sudo apt-get install -y jq
#
# Immportant: These work in Bash - they have issues in ZShell.
#
# Example Call (bash)
# source deletepods.sh <NAMESPACE>(Optional)
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo

NAMESPACE=$1

pod_dump_csv=$(kubectl get pods -A -o=jsonpath="{range .items[*]}{.metadata.namespace},{.metadata.name},{.metadata.status.phase}{'\n'}{end}")

IFS=$'\n'
for line in $pod_dump_csv; do

  pod_namespace=$(echo $line | awk -F, {'print $1'})
  pod_name=$(echo $line | awk -F, {'print $2'})
  pod_status=$(echo $line | awk -F, {'print $3'})

    if [ $# -eq 0 ]  && [ -z "${NAMESPACE}" ]; then
	  pod_namespace=$(echo $line | awk -F, {'print $1'})
	else
	  if [[ "$NAMESPACE" == "$pod_namespace" ]]; then
	    pod_namespace=$NAMESPACE
	  else
		continue
	  fi
	fi

  echo "Should I delete pod $pod_name in namespace $pod_namespace (y/n)"
  read deletepod
  
  if [[ "$deletepod" == "Y" ]] || [[ "$deletepod" == "y" ]]; then
    if [[ "$pod_status" == "Terminating" ]]; then
      echo "Pod in Terminating status - forcing deletion"
      kubectl delete pod $pod_name --grace-period=0 --force --namespace $pod_namespace
    else
      kubectl delete pod $pod_name --namespace $pod_namespace
    fi
  fi
	  
done
