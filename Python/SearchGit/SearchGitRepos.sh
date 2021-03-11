#!/bin/bash

##!/bin/sh

# ************************************************************************
# Script: SearchGitRepos.sh
# Author: Richard Knechtel
# Date: 02/12/2021
# Description: This script will allow you to Search across multiple
#               Git Repos
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# Example Call:
# SearchGitRepos.sh MySearchString /opt/GitRepos
#
# ************************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
echo Parameters Passed = $1 $2
echo

SEARCHTERM=$1
set SEARCHPATH=$2

# Check if we got ALL parameters
if [ $# -eq 0 ]  || [ -z "$SEARCHTERM" ] && [ -z "$SEARCHPATH" ]
 then
  echo "[USAGE]: SearchGitRepos.sh arg1 arg2"
  echo "arg1 = Search Term (Example: MySearchTerm)"
  echo "arg2 = Search Path (Example: /opt/GitRepos)"
  exit 1
fi


# set Script Path
SCRIPTPATH=/opt/Scripts/Python/SearchGit

echo

echo "*********************************************************************************************************"
echo "Starting SearchGitRepos"
echo "*********************************************************************************************************"

python3 %SCRIPTPATH%\SearchGitRepos.py $SEARCHTERM $SEARCHPATH

# Lets get out of here!
exit 0

# END
