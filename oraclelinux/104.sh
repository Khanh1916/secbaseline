#!/bin/bash

if ! findmnt -l | grep /tmp | grep -q nodev; then
  echo "FAIL: /tmp partition nodev option is not configured"
  exit 1
fi

echo "PASS: /tmp partition nodev option is configured"
exit 0
