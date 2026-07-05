# **********************************************************************************************************************
# Script: geneasyrsa.sh
# Author: Richard Knechtel
# Description: This will geneerate an easysa certificate and key for a passed in username and put them in the Folders:
# For mycompany Employees:
# ~/projects/Security/CACertificates
# For contractor:
# ~/projects/Security/CACertificates-contractor
#
# Paramter: AWSUSERNAME
# Paramter: IScontractor (optional) - pass "iscontractor" to use the contractor PKI and output folder
#
# Note: This script requires the project "easyrsa"
# GIT URL: https://github.com/OpenVPN/easy-rsa.git
# **********************************************************************************************************************

AWSUSERNAME=$1
IScontractor=$2

echo "Starting create of certificate and key"
cd ~/projects/Security/easy-rsa/easyrsa3
if [ "${IScontractor}" = "iscontractor" ]; then
	./easyrsa --pki=pki-contractor build-client-full ${AWSUSERNAME}.client1.domain.tld nopass
else
	./easyrsa build-client-full ${AWSUSERNAME}.client1.domain.tld nopass
fi
echo "Done creating certificate and key"

if [ "${IScontractor}" = "iscontractor" ]; then
	echo "Copying certificate and key for contractor user to ~/projects/Security/CACertificates-contractor/"
	cp pki-contractor/issued/${AWSUSERNAME}.client1.domain.tld.crt ~/projects/Security/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.crt
	cp pki-contractor/private/${AWSUSERNAME}.client1.domain.tld.key ~/projects/Security/CACertificates-contractor/${AWSUSERNAME}.client1.domain.tld.key
else
	echo "Copying certificate and key For mycompany user to ~/projects/Security/CACertificates/"
	cp pki/issued/${AWSUSERNAME}.client1.domain.tld.crt ~/projects/Security/CACertificates/${AWSUSERNAME}.client1.domain.tld.crt
	cp pki/private/${AWSUSERNAME}.client1.domain.tld.key ~/projects/Security/CACertificates/${AWSUSERNAME}.client1.domain.tld.key
fi

echo "Done copying certificate and key."


