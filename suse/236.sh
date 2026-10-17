#!/bin/bash

if systemctl is-enabled cups &> /dev/null; then
  echo "FAIL: cups is enabled"
  exit 1
fi

echo "PASS: cups is not enabled"
exit 0
