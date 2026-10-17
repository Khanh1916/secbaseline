#!/bin/bash

if ! rpm -q libselinux &> /dev/null; then
  echo "FAIL: libselinux is not installed"
  exit 1
fi

echo "PASS: libselinux is installed"
exit 0
