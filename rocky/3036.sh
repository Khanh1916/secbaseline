#!/bin/bash

if systemctl is-enabled avahi-daemon &> /dev/null; then
  echo "FAIL: avahi-daemon is enabled"
  exit 1
fi

echo "PASS: avahi-daemon is disabled or not found"
exit 0
