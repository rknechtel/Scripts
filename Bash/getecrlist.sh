   #!/bin/bash
# *********************************************************************
# Script:getecr.sh
# Author: Richard Knechtel
# Date: 06/02/2025
# Description: This will get a list of ECR resources
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


# Works:

# repositories[*]
# .repositoryArn
# .repositoryName
# .createdAt

# .imageDetails[*]
# .imageDigest
# .imageTag
# .imagePushedAt
# .lastRecordedPullTime

printf "ECR Repository\tECR Repository Image\tImage Pushed At\n"
for repo in $(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text); do
  for image in $(aws ecr list-images --repository-name $repo --query 'imageIds[*].imageDigest' --output text); do   
    for itempushedat in $(aws ecr describe-images --repository-name $repo --image-ids imageDigest=$image --query 'imageDetails[*].imagePushedAt' --output text); do
      printf "${repo}\t${image}\t${itempushedat}\n"
    done
  done
done


