#!/bin/bash

if rpm -q samba &> /dev/null; then
  echo "FAIL: samba package is installed"
  exit 1
fi

echo "PASS: package samba is not installed"
exit 0
