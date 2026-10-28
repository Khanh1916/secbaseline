#!/bin/bash

if rpm -q tcpd &> /dev/null; then
  echo "PASS: TCP Wrappers (tcpd) is installed"
  exit 0
fi

echo "FAIL: TCP Wrappers (tcpd) is not installed"
exit 1
