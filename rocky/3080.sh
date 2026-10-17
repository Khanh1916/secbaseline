#!/bin/bash

if rpm -q audit &> /dev/null; then
  echo "PASS: Audit is installed"
  exit 0
fi

echo "FAIL: Audit is not installed"
exit 1
