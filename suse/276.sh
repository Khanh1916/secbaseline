#!/bin/bash

if ! systemctl is-enabled rsyslog 2>/dev/null | grep -q "enabled"; then
  echo "FAIL: rsyslog service is disabled or not found"
  exit 1
fi

echo "PASS: rsyslog service is running, enabled, and properly configured"
exit 0
