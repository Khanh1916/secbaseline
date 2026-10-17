#!/bin/bash

if rpm -q xorg-x11-server &> /dev/null; then
  echo "FAIL: Package xorg-x11-server-common is installed"
  exit 1
fi

echo "PASS: Package xorg-x11-server-common is not installed"
exit 0
