#!/bin/bash

# *********************************************************************
# Script: convertmdtodoc.sh
# Author: Richard Knechtel
# Date: 03/27/2026
# Description: This convert a MarkDown file to a Word Document.
#
# Parameters: Markdown file (file name)
#
# Note: Requires pandoc
#
# Example Call (bash)
# ./convertmdtodoc.sh <MARKDOWN_FILE>
#
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo

# Get parameters
#echo Parameters Passed = $1
#echo

# Check if a file was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <markdown-file>"
  exit 1
fi

INPUT="$1"

# Check if the file exists
if [ ! -f "$INPUT" ]; then
  echo "Error: File '$INPUT' not found."
  exit 1
fi

# Check if the file has a .md or .markdown extension
if [[ "$INPUT" != *.md && "$INPUT" != *.markdown ]]; then
  echo "Error: File must have a .md or .markdown extension."
  exit 1
fi

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
  echo "Error: pandoc is not installed. Install it from https://pandoc.org/installing.html"
  exit 1
fi

# Replace the extension with .docx
OUTPUT="${INPUT%.*}.docx"

# Convert using pandoc
pandoc "$INPUT" -o "$OUTPUT"

echo "Converted '$INPUT' -> '$OUTPUT'"