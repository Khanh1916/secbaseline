#!/bin/bash

if rpm -q rsh &> /dev/null; then
  echo "FAIL: rsh service is available"
  exit 1
fi

echo "PASS: rsh is not installed"
exit 0
