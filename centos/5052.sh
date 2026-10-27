#!/bin/bash

PACKAGES="talk talk-server"

found=""
for p in $PACKAGES; do
  rpm -q "$p" >/dev/null 2>&1 && found="$found $p"
done

if [ -n "$found" ]; then
  echo "FAIL: A talk client or server is installed:$found"
  exit 1
fi

echo "PASS: No talk client or server is installed (checked: $PACKAGES)"
exit 0
