#!/bin/bash

if rpm -q squid &> /dev/null; then
  echo "FAIL: squid package is installed"
  exit 1
fi

echo "PASS: package squid is not installed"
exit 0

