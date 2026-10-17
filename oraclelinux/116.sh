#!/bin/bash

if ! findmnt -l | grep /home | grep -q nodev; then
  echo "FAIL: /home partition nodev option is not configured"
  exit 1
fi

echo "PASS: /home partition nodev option is configured"
exit 0
