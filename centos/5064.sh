#!/bin/bash

if rpm -q tcp_wrappers &> /dev/null; then
  echo "PASS: TCP Wrapper is installed"
  exit 0
fi

echo "FAIL: TCP Wrapper is not installed"
exit 1
