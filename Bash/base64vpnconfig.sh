# #!/bin/bash
# *********************************************************************
# Script: base64vpnconfig.sh
# Author: Richard Knechtel
# Date: 06/04/2021
# Description: This will base64 ecode VPN Config files into 1 line 
#              for putting into GitHub/GitLab/AzureDevOps.
#
# Parameters: 
# Encode/Decode
# VPN Config File name`
#
# Example Call (bash)
# source base64vpnconfig.sh <FULL_VPN_CONFIG_FILE_NAME_WITH_EXTENSION>
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
echo Parameters Passed = $1
echo

ECODE_DECODE=$1
VPN_CONFIG_FILE_NAME=$2

usage()
{
  echo "[USAGE]: base64vpnconfig.sh arg1 arg2"
  echo "arg1 = Encode or Decode (Example: encode | decode)"
  echo "arg2 = VPN COnfig File Name With Extension (Example: client-config-VPNUser.ovpn)"
}


# Check if we got ALL parameters
if [ $# -eq 0 ] && [ -z "${ECODE_DECODE}" ]  && [ -z "${VPN_CONFIG_FILE_NAME}" ]; then
 usage
 return 1 
fi

if [[ "$ECODE_DECODE" == "encode" ]]; then
  cat ${VPN_CONFIG_FILE_NAME} | base64 -w 0 >${VPN_CONFIG_FILE_NAME}.base64
elif [[ "$ECODE_DECODE" == "decode" ]]; then
  base64 -d ${VPN_CONFIG_FILE_NAME}.base64 >${VPN_CONFIG_FILE_NAME}.decodebase64
fi



# END
