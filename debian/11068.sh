#!/bin/bash

if ! systemctl status ufw 2>/dev/null | grep -q "Active: active"; then
 echo "FAIL: UFW firewall status is inactive"
 exit 1
fi

echo "PASS: UFW firewall is active and running"
exit 0
