#!/bin/bash

if sestatus | grep "SELinux status" | grep -q "disabled"; then
  echo "FAIL: SELinux status is disabled"
  exit 1
fi

echo "PASS: SELinux status is enabled"
exit 0
