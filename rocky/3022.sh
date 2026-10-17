#!/bin/bash

if rpm -q prelink &>/dev/null; then
  echo "FAIL: prelink is installed"
  exit 1
fi

echo "PASS: prelink is not installed"
exit 0
