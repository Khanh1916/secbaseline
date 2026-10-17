#!/bin/bash

if ! systemctl status rsyslog 2>/dev/null | grep -q "Active: active (running)"; then
  echo "rsyslog service is not running, not enabled, or not installed"
  exit 1
fi

if ! systemctl is-enabled rsyslog 2>/dev/null | grep -q "enabled"; then
  echo "rsyslog service is running but not enabled for startup"
  exit 1
fi

echo "rsyslog service is running, enabled, and properly configured"
exit 0
