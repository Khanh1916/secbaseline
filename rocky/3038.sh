#!/bin/bash

if rpm -q dhcp-server &> /dev/null; then
  echo "FAIL: dhcp-server is installed"
  exit 1
fi

echo "PASS: dhcp-server is not installed"
exit 0
