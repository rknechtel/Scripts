# #!/bin/bash
# *********************************************************************
# Script: urlencodedecode.sh
# Author: Richard Knechtel
# Date: 04/29/2026
# Description: This will URL Encode or URL Decode a value passed in.
#
# Parameters: 
# Encode or Decode: <e|d>
# Note:  e = Encode, d = Decode
#
# Note: Requires Python 3
#
# Example Call (bash)
# ./urlencodedecode.sh <e|d> <string>
#  echo "string" | urlencodedecode.sh <e|d>
#
# NOTE: Wrap values containing !, %, $, backticks, etc. in SINGLE quotes to
# prevent bash history expansion / variable interpolation. 
# Example:
# ./urlencodedecode.sh e '6%lu:a<k!uGu@rn]E}g*<gLv8An+7O'
#
# *********************************************************************

echo
echo "Running as user: $USER"
echo


mode="$1"
shift || true
input="${1:-$(cat)}"

case "$mode" in
    e|E)
        printf '%s' "$input" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''))"
        ;;
    d|D)
        printf '%s' "$input" | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))"
        ;;
    *)
        echo "Usage: $(basename "$0") <e|d> <string>" >&2
        echo "  e = Encode, d = Decode" >&2
        exit 1
        ;;
esac
