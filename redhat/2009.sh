#!/bin/bash

if ! findmnt -l | grep /dev/shm | grep -q nodev; then
  echo "FAIL: /dev/shm partition nodev option is not configured"
  exit 1
fi

echo "PASS: /dev/shm partition nodev option is configured"
exit 0
