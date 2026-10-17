#!/bin/bash

if ! systemctl is-enabled ntpd &> /dev/null; then
  echo "FAIL: ntpd service is not enabled"
  exit 1
fi

echo "PASS: ntpd service is enabled"
exit 0
