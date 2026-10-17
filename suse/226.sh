#!/bin/bash

if rpm -q setroubleshoot &> /dev/null; then
  echo "FAIL: setroubleshoot is installed"
  exit 1
fi

echo "PASS: setroubleshoot is not installed"
exit 0
