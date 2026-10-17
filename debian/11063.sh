#!/bin/bash

if ! dpkg -s tcpd 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "FAIL: package 'tcpd' is not installed and no information is available"
  exit 1
fi

echo "PASS: TCP wrapper 'tcpd' is installed"
exit 0
