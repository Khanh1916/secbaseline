#!/bin/bash

if ! grep -i "banner" /etc/issue &> /dev/null; then
  echo "FAIL: Login banner is not configured"
  exit 1
fi

echo "PASS: Login banner is configured"
exit 0
