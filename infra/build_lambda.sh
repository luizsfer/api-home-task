#!/bin/bash

# Change to the app directory
cd app || exit

# Create a build directory and install dependencies
mkdir -p build
pip3 install -q -r requirements.txt --target build

# Add the application code to the build directory
cp -r ./* build/

# Change to the build directory
cd build || exit

# Create the Lambda zip package
zip -r9 -q ../lambda.zip . -x "bin/*" "*.dist-info/*"

# Clean up the build directory
cd ..
rm -rf build

# Change back to the root directory
cd ..
