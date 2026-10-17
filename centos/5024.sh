#!/bin/bash

if sestatus | grep "SELinux mode" | grep -q "disabled"; then
  echo "FAIL: SELinux mode is disabled"
  exit 1
fi

echo "PASS: SELinux mode is Permissive or Enforcing"
exit 0
