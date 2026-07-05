# Project: bash scripts


*This is a collection of bash scripts that are general purpose  *  


**Important**  
These scripts work fine in Bash but have issues in ZShell. Sos run them in a Bash shell.

**Required Items Used:**  
awscli  
jq  

## Installation of Required Items

Program: jq  
Install jq on Ubuntu Linux:
sudo apt-get install -y jq  

AWS CLI:  
Install AWS CLI in Ubuntu Linux:  
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  
unzip awscliv2.zip  
sudo ./aws/install  
.  

## Scripts  

### awsauth.sh

**Using AWS Auth script**  
source awsauth.sh  <TOKEN_CODE>  

**Note:**  



### awsswitchrole.sh

**Using AWS Switch Role**  
source awsswitchrole.sh  <ROLE_ARN> <ROLE_SESSION_NAME>  

**Note:**  

    ROLE_ARN comes from: .aws/config  
    ROLE_SESSION NAME: Is any name you want to give it (Example: AWSCLI-Session)

### awsswitchrolemfa.sh

**Using AWS Switch Role with MFA**  
source awsswitchrolemfa.sh  <ROLE_ARN> <ROLE_SESSION_NAME> <TOKEN_CODE>   

**Note:**  

    ROLE_ARN comes from: .aws/config  
    ROLE_SESSION_NAME: Is any name you want to give it (Example: AWSCLI-Session)e it (Example: AWSCLI-Session)

**Note 2:**  

    TOKEN_CODE comes from:  
    1Password --> Account --> one time password  

## awsshowenv.sh

**Using AWS Show Environment Variables Script**  
This swcript will show any AWS Environment Variables you have set.  

./awsshowenv.sh

### lambdatest.sh  

**Using the Lambda Test Script**  
This script will alllow you to test a Lambda from the command line.  

./lambdatest.sh  <LAMBDA_ARN> <LAMBDA_PAYLOAD>  

**Note:**  

    LAMBDA_ARN comes from the Lambda itself (in AWS Lambda Console)  
    LAMBDA_PAYLOAD is a JSON file with the payload to send to the lambda in it. (full path to JSON file)  

--- 

### getroute53info.sh  

This script will output the Hosted Zone Information for the DNS Name passed in.  
It will also List all Hosted Zone Resource Records.  

**Important Note:**  

This script requires authenticating to AWS with either `awsauth.sh` or `awsswitchrolemfa.sh`.  

**Example Call Template (bash):**  

./getroute53info.sh [DNS_NAME]  

**Example Call (bash):**  

./getroute53info.sh mycompany.com  


### startstopec2.sh  

This script will Start and Stop an EC2 instance.  

**Important Note:**  

This script requires authenticating to AWS with either `awsauth.sh` or `awsswitchrolemfa.sh`. 

**Example Call Template (bash):**  

./startstopec2.sh [COMMAND] [INSTANCE_ID]  

Note: [COMMAND] = start | stop

**Example Call (bash):**  

./startstopec2.sh start i-02340e782fe36abcd  
./startstopec2.sh stop i-02340e782fe36abcd

