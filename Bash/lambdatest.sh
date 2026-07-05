# #!/bin/bash
# *********************************************************************
# Script: lambdatest.sh
# Author: Richard Knechtel
# Date: 09/09/2021
# Description: This will let you test a lambda
#
# Parameters: 
#            Lambda ARN
#            Lambda Payload (JSON)
#
# Example script to test lambda on command line:
# Ref: http://docs.aws.amazon.com/cli/latest/reference/lambda/invoke.html
# Correct (normally): $ aws lambda invoke raw-in-base64-out --function-name myFunction --payload '{"key1":"value1"}' outputfile.txt
# Correct (Windows): aws lambda invoke raw-in-base64-out --function-name myFunction --payload "{""key1"": ""value1""}" outputfile.txt
#
# Example Call (bash)
# ./lambdatest.sh arn:aws:lambda:us-east-1:123456789012:function:MyLambda-dev /projects/my-lambda/lambdaconsoletests/dev/CheckLambdaStatus.json
#
#
# *********************************************************************

# *********************************************************************
# Note: 
# Replace: 123456789012
# With your AWS Account Number
# *********************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
echo Parameters Passed = $1 $2
echo

LAMBDA_ARN=$1
LAMBDA_PAYLOAD=$(<$2)
echo "Lambda Payload = " $LAMBDA_PAYLOAD

usage()
{
  echo "[USAGE]: lambdatest.sh arg1 arg1"
  echo "arg1 = Lambda ARN (Example: arn:aws:lambda:us-east-1:123456789012:function:Mylambda-dev)"
  echo "arg2 = Lambda payload (JSON File) (Example: /projects/my-lambda/lambdaconsoletests/CheckLambdaStatus.json)"
}

# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${LAMBDA_ARN}" ] && [ -z "${LAMBDA_PAYLOAD}" ]
 then
  usage
  exit 1
fi

INVOKE_TYPE="Event"

aws lambda invoke --cli-binary-format raw-in-base64-out --function-name "$LAMBDA_ARN" --invocation-type "$INVOKE_TYPE" --payload "$LAMBDA_PAYLOAD" lambdaresponse.json

# END
