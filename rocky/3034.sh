#!/bin/bash

if rpm -q xinetd &> /dev/null; then
  echo "FAIL: xinetd is installed"
  exit 1
fi

echo "PASS: xinetd is not installed"
exit 0
