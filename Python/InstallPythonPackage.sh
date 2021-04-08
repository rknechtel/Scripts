#!/bin/bash

##!/bin/sh

# *********************************************************************
# Script: InstallPythonPackage.sh
# Author: Richard Knechtel
# Date: 02/27/2020
# Description: This will install new python 3 packages on Linux
#
# Note: This script must be run as admin - use sudo
#
# Parameters: Python Package Name
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
echo Parameters Passed = $1
echo

PYTHONPACKAGE=$1

# Check if we got ALL parameters
if [ $# -eq 0 ]  && [ -z "$PYTHONPACKAGE" ]
 then
  echo "[USAGE]: InstallPythonPackage.sh arg1"
  echo "arg1 = Python Package Name (Example: pywinrm)"
  exit 1
fi

python3 -m pip install $PYTHONPACKAGE

# Lets get out of here!
exit 0

# END
