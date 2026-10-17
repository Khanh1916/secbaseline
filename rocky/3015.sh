#!/bin/bash

if ! findmnt /var/log/audit &> /dev/null; then
  echo "FAIL: /var/log/audit partition is not configured"
  exit 1
fi

echo "PASS: /var/log/audit partition is configured"
exit 0
