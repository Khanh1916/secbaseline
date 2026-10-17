#!/bin/bash

if rpm -q aide &> /dev/null; then
  echo "PASS: AIDE is installed"
  exit 0
fi

echo "FAIL: AIDE is not installed"
exit 1
