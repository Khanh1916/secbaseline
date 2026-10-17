#!/bin/bash

if ! findmnt -l | grep /tmp | grep -q nosuid; then
  echo "FAIL: /tmp partition nosuid option is not configured"
  exit 1
fi

echo "PASS: /tmp partition nosuid option is configured"
exit 0
