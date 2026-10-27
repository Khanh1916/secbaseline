#!/bin/bash

if ! rpm -q libselinux1 &> /dev/null; then
  echo "FAIL: libselinux1 is not installed"
  exit 1
fi

echo "PASS: libselinux1 is installed"
exit 0
