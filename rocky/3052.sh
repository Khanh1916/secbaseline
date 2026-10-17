#!/bin/bash

if rpm -q talk-server &> /dev/null; then
  echo "FAIL: talk-server is installed"
  exit 1
fi

echo "PASS: talk-server is not installed"
exit 0

