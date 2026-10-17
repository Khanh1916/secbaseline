#!/bin/bash

if rpm -q telnet-server &> /dev/null; then
  echo "FAIL: Telnet server is available"
  exit 1
fi

echo "PASS: Telnet server is removed"
exit 0