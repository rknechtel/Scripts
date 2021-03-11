#!/bin/bash

##!/bin/sh

# ************************************************************************
# Script: GitRepoCloner.sh
# Author: Richard Knechtel
# Date: 02/12/2021
# Description: This script will allow you to clone or update (pull)
#               Git Repos
#
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#
# Example Call:
# GitRepoCloner.sh clone "/opt/Scripts/Python/SearchGit/sqlitedb\GitRepos.s3db" "/home/USERID/GitClonedRepos"
#
# ************************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
echo "Parameters Passed = " $1 $2
echo

GITCOMMAND=$1
DB=$2
CLONEDIR=$3

# Check if we got ALL parameters
if [ $# -eq 0 ]  || [ -z "$GITCOMMAND" ] || [ -z "$DB" ] || [ -z "$CLONEDIR" ] 
 then
  echo "[USAGE]: GitRepoCloner.sh arg1 arg2 arg3"
  echo "arg1 = A Git command (Options: clone pull)"
  echo "arg2 = SQLite Database (Example: /opt/Scripts/Python/SearchGit/sqlitedb\GitRepos.s3db)"
  echo "arg3 = Repo Clone Directory (Example: /home/USERID/GitClonedRepos)"
  exit 1
fi


# set Script Path
SCRIPTPATH=/opt/Scripts/Python/GitCloner

echo 

echo "*********************************************************************************************************"
echo "Cloning/Update (pull) Git Repos"
echo "*********************************************************************************************************"

python3 $SCRIPTPATH\GitRepoCloner.py $GITCOMMAND $DB $CLONEDIR

# Lets get out of here!
exit 0

# END
