# #!/bin/bash
# *********************************************************************
# Script: getsecrests.sh
# Author: Richard Knechtel
# Date: 04/02/2025
# Description: This will get the username and password from a 
#              Secrets Manager Secret
#
# Note: You must have active AWS Access keys for this to work and MFA enabled and setup.
#
# Note: You MUST have mfa_serial set in your .aws/config file.
# Example:
# [default]
# region = us-east-1
# output = json
# mfa_serial=arn:aws:iam::123456789012:mfa/MyMFADevice
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
# *********************************************************************

# *********************************************************************
# Note: 
# Replace: 123456789012
# With your AWS Account Number
# *********************************************************************

# Get parameters
#echo Parameters Passed = $1
#echo

SECRET_NAME=$1


usage()
{
  echo "[USAGE]: getsecrests.sh arg1"
  echo "arg1 = Secret ARN (Example: arn:aws:secretsmanager:us-east-1:123456789012:secret:rds/mycompany-ap-ro-vPjFhe)"
  echo "NOTE: Requires AWS CLI and program jq!"
  echo "NOTE: NOTE2: You must have active AWS Access keys for this to work and MFA enabled and setup."
  echo "NOTE3: You MUST have mfa_serial set in your .aws/config file - see script for example"
}


# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${SECRET_NAME}" ]; then
 usage
 return 1 
fi

secret_value=`aws secretsmanager get-secret-value --secret-id $SECRET_NAME`

username=$(echo $secret_value | jq -rc '.SecretString' | jq -rc '.username')
password=$(echo $secret_value | jq -rc '.SecretString' | jq -rc '.password')

echo $username
echo $password
