#!/bin/bash

if ! findmnt -l | grep /tmp | grep -q noexec; then
  echo "FAIL: /tmp partition noexec option is not configured"
  exit 1
fi

echo "PASS: /tmp partition noexec option is configured"
exit 0
