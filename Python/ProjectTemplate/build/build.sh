# *********************************************************************
# Script: build.sh
# Author: Richard Knechtel
# Date: 05/20/2021
# Description: This will build My Lambda
# Example Call (bash):
#   build.sh
#
#
# *********************************************************************

echo
echo "Running build for My Lamabda F"
echo

cd build

echo
echo "Copying needed files for Lambda to v-env site packages folder"
echo
cp -r ../classes ../v-env/lib/python3.8/site-packages
cp -r ../config ../v-env/lib/python3.8/site-packages
cp -r ../modules ../v-env/lib/python3.8/site-packages
cp -r ../lambda.py ../v-env/lib/python3.8/site-packages
cp -r ../__init__.py ../v-env/lib/python3.8/site-packages

echo
echo "creating Lambda zip file"
echo
cd ../v-env/lib/python3.8/site-packages/
zip -r9 lambda_function.zip *
mv lambda_function.zip ../../../../

echo
echo "Finished running build for Lamabda"
echo
# Lets get out of here!
exit 0

# END