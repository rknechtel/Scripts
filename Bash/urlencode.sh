#!/usr/bin/env bash
# Usage: urlencode.sh <string>
#        echo "string" | urlencode.sh

input="${1:-$(cat)}"
printf '%s' "$input" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''))"
