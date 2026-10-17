#!/bin/bash

if ! findmnt /home &> /dev/null; then
  echo "FAIL: /home partition is not configured"
  exit 1
fi

echo "PASS: /home partition is configured"
exit 0
