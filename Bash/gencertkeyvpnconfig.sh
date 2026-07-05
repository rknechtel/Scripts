# **********************************************************************************************************************
# Script: gencertkeyvpnconfig.sh
# Author: Richard Knechtel
# Description: 
# This will geneerate an easyrsa certificate and key for a passed in username and the VPN configuration file 
# and put them in the Folders:
# For mycompany Employees:
# ~/<BASEFOLDER>/easy-rsa-certskeysconfigs/CACertificates
# For contractor:
# ~/<BASEFOLDER>/easy-rsa-certskeysconfigs/CACertificates-contractor
#
# Paramter: AWSUSERNAME
# Paramter: iscontractor (optional) - pass "iscontractor" to use the contractor PKI and output folder
#
# Example Calls:
# For mycompany Employees:
# ./gencertkeyvpnconfig.sh BobSmith secretsmanager
# ./gencertkeyvpnconfig.sh BobSmith 1password
# ./gencertkeyvpnconfig.sh BobSmith local
# For contractor:
# ./gencertkeyvpnconfig.sh BobSmith secretsmanager iscontractor
# ./gencertkeyvpnconfig.sh BobSmith 1password iscontractor
# ./gencertkeyvpnconfig.sh BobSmith local iscontractor
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
#
# This script requires:
# 1) The project "easyrsa"
#    GIT URL: https://github.com/OpenVPN/easy-rsa.git
# 2) Zip program
# 3) The 1Password CLI
#
# **********************************************************************************************************************

AWSUSERNAME=$1
STOREWITH=$2 # Valid options 1password | secretsmanager | local
iscontractor=$3 # Optional

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
  echo "arg2 = StoreWith (Valid options 1password | secretsmanager)"
  echo "arg3 (Optional) = iscontractor (Signifies a contractor user)"
  echo "NOTE: Requires AWS CLI and programs easy-rsa and zip!"
}


# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "${TOKEN_CODE}" ]  && [ -z "${STOREWITH}" ]; then
 usage
 return 1 
fi

echo "STOREWITH = ${STOREWITH}"
case "${STOREWITH}" in
    1password|secretsmanager|local)
        ;;
    *)
        echo "Error: STOREWITH must be either '1password' or 'secretsmanager' or 'local'"
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
if [[ "${STOREWITH}" == "1password" ]]; then
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
echo "Starting creation of certificate and key"
cd ${BASEFOLDER}/easy-rsa/easyrsa3
if [ "${iscontractor}" = "iscontractor" ]; then
	./easyrsa --batch --pki=pki-contractor build-client-full ${AWSUSERNAME}.client1.domain.tld nopass
else
	./easyrsa --batch build-client-full ${AWSUSERNAME}.client1.domain.tld nopass
fi
echo "Done creating certificate and key"

echo "Copying certificate and key."
if [ "${iscontractor}" = "iscontractor" ]; then
	echo "Copying certificate and key for contractor user to /CACertificates-contractor/"
	cp pki-contractor/issued/${AWSUSERNAME}.client1.domain.tld.crt ${CERTKEYCONFIGFOLDER}/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.crt
	cp pki-contractor/private/${AWSUSERNAME}.client1.domain.tld.key ${CERTKEYCONFIGFOLDER}/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.key
        CRT_FILE="${CERTKEYCONFIGFOLDER}/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.crt"
        KEY_FILE="${CERTKEYCONFIGFOLDER}/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.key"
else
	echo "Copying certificate and key For mycompany user to /CACertificates/"
	cp pki/issued/${AWSUSERNAME}.client1.domain.tld.crt ${CERTKEYCONFIGFOLDER}/CACertificates/${AWSUSERNAME}.client1.domain.tld.crt
	cp pki/private/${AWSUSERNAME}.client1.domain.tld.key ${CERTKEYCONFIGFOLDER}/CACertificates/${AWSUSERNAME}.client1.domain.tld.key
        CRT_FILE="${CERTKEYCONFIGFOLDER}/CACertificates/${AWSUSERNAME}.client1.domain.tld.crt"
        KEY_FILE="${CERTKEYCONFIGFOLDER}/CACertificates/${AWSUSERNAME}.client1.domain.tld.key"
fi

echo "Done copying certificate and key."

# ************************************************************************
# Create VPN Configuration File
# ************************************************************************
echo "Creating VPN Configuration File."

if [ "${iscontractor}" = "iscontractor" ]; then
  cp $CERTKEYCONFIGFOLDER/ClientConfig-contractor/client-config-FirstnameLastname.ovpn $CERTKEYCONFIGFOLDER/ClientConfig-contractor/client-config-${AWSUSERNAME}.ovpn
  OVPN_FILE="${CERTKEYCONFIGFOLDER}/ClientConfig-contractor/client-config-${AWSUSERNAME}.ovpn"
else
  cp $CERTKEYCONFIGFOLDER/ClientConfig/client-config-FirstnameLastname.ovpn $CERTKEYCONFIGFOLDER/ClientConfig/client-config-${AWSUSERNAME}.ovpn
  OVPN_FILE="${CERTKEYCONFIGFOLDER}/ClientConfig/client-config-${AWSUSERNAME}.ovpn"
fi

# Extract certificate block from .crt file
CERT=$(awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "$CRT_FILE")

# Extract private key block from .key file
KEY=$(awk '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/' "$KEY_FILE")

# Replace content between <cert>...</cert> in the .ovpn file
awk -v cert="$CERT" '
  /<cert>/ { print; print cert; inside=1; next }
  /<\/cert>/ { inside=0 }
  !inside { print }
' "$OVPN_FILE" > "${OVPN_FILE}.tmp"

# Replace content between <key>...</key> in the temp file
awk -v key="$KEY" '
  /<key>/ { print; print key; inside=1; next }
  /<\/key>/ { inside=0 }
  !inside { print }
' "${OVPN_FILE}.tmp" > "${OVPN_FILE}.tmp2"

echo "Done: cert and key injected into $OVPN_FILE"

# Overwrite original and clean up
echo "Moving VPN Config File."
if [ "${iscontractor}" = "iscontractor" ]; then
	echo "Copying VPN Config file for contractor user to /ClientConfig-contractor/"
	mv "${OVPN_FILE}.tmp2" ${CERTKEYCONFIGFOLDER}/ClientConfig-contractor/${OVPN_FILE}
else
	echo "Copying VPN Config file for mycompany user to /ClientConfig/"
	mv "${OVPN_FILE}.tmp2" ${CERTKEYCONFIGFOLDER}/ClientConfig/${OVPN_FILE}
fi

echo "OpenVPNCONfig File: ${OVPN_FILE}.tmp"
rm -f "${OVPN_FILE}.tmp"

echo "Done creating VPN Configuration File."

# ************************************************************************
# Exit for now until we want to start doing the below:
exit 0
# ************************************************************************


# ************************************************************************
# Create the .zip files
# ************************************************************************
echo "Creating VPNFiles .zip files."
# Note: The -j flag (junk paths) is used to strip the directory structure from the files and only zip up the files themselves.
zip -j ${VPNFILES}/${AWSUSERNAME}-CertKeys.zip ${CRT_FILE} ${KEY_FILE}
zip -j ${VPNFILES}/${AWSUSERNAME}-VPNConfig.zip ${OVPN_FILE}

# ************************************************************************
# Store using local
# ************************************************************************
if [[ "${STOREWITH}" == "local" ]]; then
  echo "Keeping entries stored locally."
  exit 0
fi

# ************************************************************************
# Store using 1Password
# ************************************************************************
if [[ "${STOREWITH}" == "1password" ]]; then
  echo "Create 1Password document entries."
  op document create ${VPNFILES}/${AWSUSERNAME}-CertKeys.zip --vault "VPNFiles" --title "${AWSUSERNAME} VPN Cert and Key Files" --file-name "${AWSUSERNAME}-CertKeys.zip" --tags Root/mycompany/VPNFiles
  op document create ${VPNFILES}/${AWSUSERNAME}-VPNConfig.zip --vault "VPNFiles" --title "${AWSUSERNAME} VPN Config File" --file-name "${AWSUSERNAME}-VPNConfig.zip" --tags Root/mycompany/VPNFiles
  echo "Done creating 1Password document entry."
fi

# ************************************************************************
# Store using Secrets Manager
# ************************************************************************
if [[ "${STOREWITH}" == "secretsmanager" ]]; then
  echo "Create AWS Secrets Manager entries."
  # Pre-Base64 Encode the files
  CERTKEYS_B64=$(base64 -w 0 ${VPNFILES}/${AWSUSERNAME}-CertKeys.zip)
  VPNCONFIG_B64=$(base64 -w 0 ${VPNFILES}/${AWSUSERNAME}-VPNConfig.zip)

# Build the JSON payload
SECRET_JSON=$(cat <<EOF
{
    "${AWSUSERNAME}-CertKeys": "${CERTKEYS_B64}",
    "${AWSUSERNAME}-VPNConfig": "${VPNCONFIG_B64}"
}
EOF
)

  # Create the secret
  aws secretsmanager create-secret --name "vpn/${AWSUSERNAME}" \
      --description "${AWSUSERNAME} VPN certificates, keys and config" \
      --secret-string "${SECRET_JSON}" \
      --tags '[
          {"Key": "Project", "Value": "mycompany VPN"},
          {"Key": "Environment", "Value": "Production"},
          {"Key": "CostCenter", "Value": "1005"},
          {"Key": "Terraform", "Value": "False"},
          {"Key": "ManagedBy", "Value": "Automation"},
          {"Key": "Owner", "Value": "DevOps"}
      ]'
  
  echo "Done creating AWS Secrets Manager entries."

  # To retrieve and decode a value later:
  # aws secretsmanager get-secret-value --secret-id "vpn/${AWSUSERNAME}" --query "SecretString" --output text | jq -r '."${AWSUSERNAME}-CertKeys"' | base64 -d > ${AWSUSERNAME}-CertKeys.zip
  # aws secretsmanager get-secret-value --secret-id "vpn/${AWSUSERNAME}" --query "SecretString" --output text | jq -r '."${AWSUSERNAME}-VPNConfig"' | base64 -d > ${AWSUSERNAME}-VPNConfig.zip
  # Example: 
  # aws secretsmanager get-secret-value --secret-id "vpn/BobSmith" --query "SecretString" --output text | jq -r '."BobSmith-CertKeys"' | base64 -d > BobSmith-CertKeys.zip
  # aws secretsmanager get-secret-value --secret-id "vpn/BobSmith" --query "SecretString" --output text | jq -r '."BobSmith-VPNConfig"' | base64 -d > BobSmith-VPNConfig.zip
  
  # To update the secret values later use:
  # aws secretsmanager put-secret-value --secret-id "vpn/${AWSUSERNAME}" --secret-string "${SECRET_JSON}"
  # Example: 
  # aws secretsmanager put-secret-value --secret-id "vpn/BobSmith" --secret-string "${SECRET_JSON}"
fi