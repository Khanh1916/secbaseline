#!/bin/bash

if ! findmnt -l | grep /dev/shm | grep -q nosuid; then
  echo "FAIL: /dev/shm partition nosuid option is not configured"
  exit 1
fi

echo "PASS: /dev/shm partition nosuid option is configured"
exit 0
