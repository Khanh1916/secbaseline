#!/bin/bash

if ! systemctl is-enabled chronyd &> /dev/null; then
  echo "FAIL: chronyd service is not enabled"
  exit 1
fi

echo "PASS: chronyd service is enabled"
exit 0
