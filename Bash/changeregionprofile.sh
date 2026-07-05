
# **********************************************************
# Script: changeregionprofile.sh
# Description: Change the AWS Region and AWS Profile in current terminal
#
# Example usage:
# source ./changeregionprofile.sh us-west-1 rknechtelwest1
# source ./changeregionprofile.sh us-west-2 rknechtelwest2
# source ./changeregionprofile.sh us-east-1 rknechteleast1
# source ./changeregionprofile.sh us-east-2 rknechteleast2
# ***********************************************************

echo Parameters Passed: $1 $2

export AWS_DEFAULT_REGION=$1
export AWS_PROFILE=$2


export AWS_DEFAULT_REGION=$(echo $AWS_DEFAULT_REGION)
export AWS_PROFILE=$(echo $AWS_PROFILE)

echo AWS Region Changed To:
echo $AWS_DEFAULT_REGION
echo AWs Profile Changed To:
echo $AWS_PROFILE
