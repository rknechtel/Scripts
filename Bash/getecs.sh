 #!/bin/bash
# *********************************************************************
# Script:getecs.sh
# Author: Richard Knechtel
# Date: 06/02/2025
# Description: This will get a list of ECS resources
#
# Parameters: 
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
# ./getecs.sh
#
# *********************************************************************

#printf
#printf "Running as user: $USER"
#printf

# Get parameters
#printf Parameters Passed = $1
#printf

# Get list of ECS Clusters
ECS_CLUSTERS=($(aws ecs list-clusters | jq -r '.clusterArns[]'))

printf "ECS Clusters Analysis\n"
printf "=================================================\n\n"

for cluster in "${ECS_CLUSTERS[@]}" ; do
    printf "Cluster: $cluster\n"

    # Get list of Services on an ECS Cluster
    ECS_CLUSTER_SERVICES=($(aws ecs list-services --cluster "$cluster" | jq -r '.serviceArns[]'))
    
    for service in "${ECS_CLUSTER_SERVICES[@]}" ; do
        printf "\n  - Service: $service\n"

        # Get Service Details (Task Def and Running Count)
        SERVICE_JSON=$(aws ecs describe-services --cluster "$cluster" --services "$service")
        
        TASK_DEFINITION=$(echo "$SERVICE_JSON" | jq -r '.services[0].taskDefinition')
        RUNNING_COUNT=$(echo "$SERVICE_JSON" | jq -r '.services[0].runningCount')
        TARGET_GROUP=$(echo "$SERVICE_JSON" | jq -r '.services[0].loadBalancers[0].targetGroupArn // "None"')

        printf "    Target Group: $TARGET_GROUP\n"
        printf "    Task Definition: $TASK_DEFINITION\n"
        printf "    Running Tasks: $RUNNING_COUNT\n"

        # Get CPU details from Task Definition
        # We grab the top-level CPU (Fargate) or sum of container CPUs (EC2)
        TASK_DEF_JSON=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION")
        
        # Task-level CPU is usually the standard for Fargate
        TASK_CPU=$(echo "$TASK_DEF_JSON" | jq -r '.taskDefinition.cpu // "0"')
        
        # Container-level CPU breakdown
        printf "    Container Definition Name and (CPU units):\n"
        echo "$TASK_DEF_JSON" | jq -r '.taskDefinition.containerDefinitions[] | "      * \(.name): \(.cpu // 0)"'

        # Math: Calculate Total CPU for this service
        # If task-level CPU is missing (common in old EC2 tasks), we sum the container CPUs
        if [ "$TASK_CPU" == "0" ] || [ "$TASK_CPU" == "null" ]; then
            TASK_CPU=$(echo "$TASK_DEF_JSON" | jq -r '[.taskDefinition.containerDefinitions[].cpu // 0] | add')
        fi

        TOTAL_SERVICE_CPU=$((TASK_CPU * RUNNING_COUNT))
        VCPU_EQUIV=$(awk "BEGIN {print $TOTAL_SERVICE_CPU/1024}")

        printf "    ---------------------------------------------\n"
        printf "    Task CPU: $TASK_CPU | Total Service CPU: $TOTAL_SERVICE_CPU units (~$VCPU_EQUIV vCPUs)\n"
    done
    printf "\n-------------------------------------------------\n\n"
done

