 #!/bin/bash
# *********************************************************************
# Script:listecsclusters.sh
# Author: Richard Knechtel
# Date: 12/13/2026
# Description: This will get a list of all ECS Clusters
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
# ./listecsclusters.sh
#
# *********************************************************************

#printf
#printf "Running as user: $USER"
#printf

# Get parameters
#printf Parameters Passed = $1
#printf

OS_TYPE=$OSTYPE
UNSUPPORTED_OS=0

# Functions:
function checkostype() {

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    OS_TYPE="linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    OS_TYPE="mac"
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    # POSIX compatibility layer and Linux environment emulation for Windows
    OS_TYPE="cygwin"
  elif [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    OS_TYPE="windows"
  elif [[ "$OSTYPE" == "win32" ]]; then
    OS_TYPE="windows"
  elif [[ "$OSTYPE" == "freebsd"* ]]; then
    # FreeBSD
    OS_TYPE="freebsd"
  else
    # Unknown.
    OS_TYPE="unknown"
  fi

  return 0 
}

function checkforjq() {

  # Note To check for an install package on MAC:
  # pkgutil --pkgs=.\+Xjq.\+
  # To install on MAC:
  # brew install jq

  # Set default values:
  IS_INSTALLED="NULL"
  SKIP_LIBJQL_CHECK="no"
  checkostype

  echo "OS Type = $OS_TYPE"

  if [[ $OS_TYPE == "linux" ]]; then
    IS_INSTALLED=$(dpkg -l | grep "jq")
  elif [[ $OS_TYPE == "mac" ]]; then
    IS_INSTALLED=$(pkgutil --pkgs=.\+Xjq.\+)	
  elif [[ $OS_TYPE == "windows" ]]; then
    IS_INSTALLED=$(winget list jq)	
  fi
  
  if [ -z "${IS_INSTALLED}" ]; then
    INSTALL_JQ="yes"
  else
    #echo "Check if jq is installed"
    if [[ ${IS_INSTALLED} = *"jq"* ]]; then
      echo "jq is installed - continuing"
      INSTALL_JQ="no"
      SKIP_LIBJQL_CHECK="yes"
    fi

    #echo "Checkif if only libjql is installed, if so intall jq command"
    if [[ ${SKIP_LIBJQL_CHECK} = "no" ]] && [[ ${IS_INSTALLED} != *"libjql"* ]]; then
      INSTALL_JQ="yes"
    fi

  fi

  # Check if JQ is installed, if not install it (based on OS Type)
  if [[ ${INSTALL_JQ} = "yes" ]]; then
    echo "Required jq is not installed, installing"

    if [[ $OS_TYPE == "linux" ]]; then
      sudo apt install jq
    elif [[ $OS_TYPE == "mac" ]]; then
      brew install jq
    elif [[ $OS_TYPE == "windows" ]]; then
      # Note: This only works on:
      # WinGet the Windows Package Manager is available on Windows 11, modern versions of Windows 10, and Windows Server 2025 as a part of the App Installer.
      # Ref: https://learn.microsoft.com/en-us/windows/package-manager/winget/
      winget install jqlang.jq
    else
      # We are not running on a supported OS
      echo "ALERT! This script does not support your OS yet. It only supports Ubuntu Linux, Windows and MAC OS. Exiting!"
      UNSUPPORTED_OS=1
    fi 

  fi

  return 0
}

# Requires program: jq
# Uncomment to check if you have jq installed, if not it will install for you (on Ubuntu)
# Note: Also picks up libjq1
echo "Checking if required jq command is installed"
checkforjq

if [[ $UNSUPPORTED_OS == 0 ]]; then
  echo " "
  echo "------------------------"
  echo "Fetching ECS Clusters..."
  echo "------------------------"

  # 1. Get the list of clusters and strips the ARN prefix to show just the names
  # 2. Extract the name (the part after the last '/')
  # 3. Sort them alphabetically
  aws ecs list-clusters --output json | jq -r '.clusterArns[] | split("/") | last' | sort

 else
  echo "Unsupoprted OS - Exiting!"

fi


