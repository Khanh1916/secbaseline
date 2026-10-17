#!/bin/bash

if ! systemctl status auditd &> /dev/null; then
  echo "FAIL: auditd service is not available"
  exit 1
fi

if systemctl is-active auditd &>/dev/null && systemctl is-enabled auditd &>/dev/null; then
  echo "PASS: auditd service is running and enabled"
  exit 0
fi

echo "FAIL: auditd service is not running and disabled"
exit 1
