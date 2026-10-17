#!/bin/bash

if grep -i "CentOS" /etc/issue &> /dev/null; then
  echo "FAIL: OS information found in banner"
  exit 1
fi

echo "PASS: OS information removed from banner"
exit 0
