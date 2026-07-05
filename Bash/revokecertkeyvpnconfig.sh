# **********************************************************************************************************************
# Script: revokecertkeyvpnconfig.sh
# Author: Richard Knechtel
# Description: 
# This will Revoke an easyrsa certificate and key for a passed in username 
#
# Saved Certs and Keys are in the Folders:
# For mycompany Employees:
# ~/<BASEFOLDER>/easy-rsa-certskeysconfigs/CACertificates
# For contractor:
# ~/<BASEFOLDER>/easy-rsa-certskeysconfigs/CACertificates-contractor
#
# PKI Folders:
# For mycompany Employees:
# ~/<BASEFOLDER>/easy-rsa/easyrsa3/pki/
# For contractor:
# ~/<BASEFOLDER>/easy-rsa/easyrsa3/pki-contractor/
#
# Paramter: AWSUSERNAME
# Paramter: DELETEFROM (1password | secretsmanager)
# Paramter: IScontractor (optional) - pass "iscontractor" to use the contractor PKI and output folder
#
# Example Calls:
# For mycompany Employees:
# ./revokecertkeyvpnconfig.sh BobSmith $DELETEFROM
# For contractor:
# ./revokecertkeyvpnconfig.sh BobSmith $DELETEFROM iscontractor
#
#
# Notes: 
#
# This folder Structure is required:
# First set the BASEFOLDER= variable to the path you want as your base path.
# <BASEFOLDER>/easy-rsa-certskeysconfigs/CACertificates
# <BASEFOLDER>/easy-rsa-certskeysconfigs/CACertificates-Revoked
# <BASEFOLDER>/easy-rsa-certskeysconfigs/CACertificates-contractor
# <BASEFOLDER>/easy-rsa-certskeysconfigs/CertsKeysRevoked-contractor
# <BASEFOLDER>/easy-rsa-certskeysconfigs/ClientConfig
# <BASEFOLDER>/easy-rsa-certskeysconfigs/VPNFiles
# This file is required for the script to work:
# <BASEFOLDER>/easy-rsa-certskeysconfigs/ClientConfig/client-config-FirstnameLastname.ovpn
#
# This script requires:
# 1) The project "easyrsa"
#    GIT URL: https://github.com/OpenVPN/easy-rsa.git
# 2) Zip program
# 3) The 1Password CLI
#
# **********************************************************************************************************************

AWSUSERNAME=$1
DELETEFROM=$2 # Valid options 1password | secretsmanager
IScontractor=$3 # Optional

BASEFOLDER=~/projects/Security
#BASEFOLDER=~/projects/AI/Automation
CERTKEYCONFIGFOLDER=${BASEFOLDER}/easy-rsa-certskeysconfigs
VPNFILES=${CERTKEYCONFIGFOLDER}/VPNFiles
CRT_FILE=""
KEY_FILE=""

usage()
{
  echo "[USAGE]: gencertkeyvpnconfig.sh arg1 arg2 arg3"
  echo "arg1 = Username (FirstnameLastname)(Example: BobSmith)"
  echo "arg2 = DeleteFrom (Valid options 1password | secretsmanager)"
  echo "arg3 (Optional) = iscontractor (Signifies a contractor user)"
  echo "NOTE: Requires AWS CLI and programs easy-rsa and zip!"
}


# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${TOKEN_CODE}" ]  && [ -z "${STOREWITH}" ]; then
 usage
 return 1 
fi

echo "DELETEFROM = ${DELETEFROM}"
case "${DELETEFROM}" in
    1password|secretsmanager)
        ;;
    *)
        echo "Error: DELETEFROM must be either '1password' or 'secretsmanager'"
        exit 1
        ;;
esac

echo "Checking for required programs."

echo "Is easy-rsa installed?"
if [[ -f "${BASEFOLDER}/easy-rsa/easyrsa3/easyrsa" ]]; then
    echo "easy-rsa found"
else
    echo "easy-rsa not found - exiting"
    exit 1
fi

echo "Is zip installed?"
if command -v zip &>/dev/null; then
    echo "zip is installed"
else
    echo "Error: zip is not installed - exiting"
    exit 1
fi

# If using 1Password
if [[ "${DELETEFROM}" == "1password" ]]; then
  echo "Is 1Password CLI (op) installed?"
  if command -v op &>/dev/null; then
    echo "1Password CLI (op) is installed"
  else
    echo "Error: 1Password CLI (op) is not installed - exiting"
    exit 1
  fi
fi

echo "We have all are required programs - lets continue."


echo "Updating easy-rsa"
cd ${BASEFOLDER}/easy-rsa/
git pull

# ************************************************************************
# Create Certificate and Key
# ************************************************************************
echo "Starting Revokation of certificate and key"
cd ${BASEFOLDER}/easy-rsa/easyrsa3
if [ "${IScontractor}" = "iscontractor" ]; then
  ./easyrsa --batch --pki=pki-contractor revoke ${AWSUSERNAME}.client1.domain.tld
else
	./easyrsa --batch revoke ${AWSUSERNAME}.client1.domain.tld
fi
echo "Done Revoking certificate and key"


echo "Moving certificate and key."
if [ "${IScontractor}" = "iscontractor" ]; then
	echo "Moving certificate and key for contractor user to /CertsKeysRevoked-contractor/"
  mv ${CERTKEYCONFIGFOLDER}/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.crt ${CERTKEYCONFIGFOLDER}/CertsKeysRevoked-contractor/${AWSUSERNAME}.client1.domain.tld.crt
  mv ${CERTKEYCONFIGFOLDER}/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.key ${CERTKEYCONFIGFOLDER}/CertsKeysRevoked-contractor/${AWSUSERNAME}.client1.domain.tld.key
else
	echo "Moving certificate and key For mycompany user to /CACertificates/"
  mv ${CERTKEYCONFIGFOLDER}/CACertificates/${AWSUSERNAME}.client1.domain.tld.crt ${CERTKEYCONFIGFOLDER}/CACertificates-Revoked/${AWSUSERNAME}.client1.domain.tld.crt
  mv ${CERTKEYCONFIGFOLDER}/CACertificates/${AWSUSERNAME}.client1.domain.tld.key ${CERTKEYCONFIGFOLDER}/CACertificates-Revoked/${AWSUSERNAME}.client1.domain.tld.key
fi

echo "Done Revoking certificate and key."

# ************************************************************************
# Generate CRL and Uploading to VPN
# ************************************************************************
echo "Generating CRL"

# Generate CRL:
cd ${BASEFOLDER}/easy-rsa/easyrsa3
./easyrsa gen-crl

# Upload CRL File:
echo "Uploading CRL"
if [ "${IScontractor}" = "iscontractor" ]; then
  aws ec2 import-client-vpn-client-certificate-revocation-list --certificate-revocation-list file://${BASEFOLDER}/easy-rsa/easyrsa3/pki-contractor/crl.pem --client-vpn-endpoint-id cvpn-endpoint-0c0f07ad452c61be2 --region us-east-1
else
	aws ec2 import-client-vpn-client-certificate-revocation-list --certificate-revocation-list file://${BASEFOLDER}/easy-rsa/easyrsa3/pki/crl.pem --client-vpn-endpoint-id cvpn-endpoint-0a26153a3d9177d85 --region us-east-1
fi

echo "Done Generating CRL and Uploading to VPN."

# ************************************************************************
# Deleting Entry from 1Password
# ************************************************************************
if [[ "${DELETEFROM}" == "1password" ]]; then
  echo "Deleting 1Password document entries."
  if ! op document delete "${AWSUSERNAME} VPN Cert and Key Files" --vault "VPNFiles"; then
    echo "Error: Failed to delete document (${AWSUSERNAME} VPN Config File) from 1Password"
    exit 1
  fi
  if ! op document delete "${AWSUSERNAME} VPN Config File" --vault "VPNFiles"; then
    echo "Error: Failed to delete document (${AWSUSERNAME} VPN Config File) from 1Password"
    exit 1
  fi
  echo "Done Deleting 1Password document entries."
fi

# ************************************************************************
# Deleting Entry from Secrets Manager
# ************************************************************************
if [[ "${DELETEFROM}" == "secretsmanager" ]]; then
  echo "Delete AWS Secrets Manager entries (Force Delete no Recovery)."
  ERROR_OUTPUT=$(aws secretsmanager delete-secret --secret-id "vpn/${AWSUSERNAME}" --force-delete-without-recovery 2>&1)

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to delete secret vpn/${AWSUSERNAME} from AWS Secrets Manager"
    echo "AWS Error: ${ERROR_OUTPUT}"
    exit 1
  fi
  
  echo "Done Deleting AWS Secrets Manager entries."

fi
