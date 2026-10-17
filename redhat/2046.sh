#!/bin/bash

if rpm -q ypserv &> /dev/null; then
  echo "FAIL: NIS server is available"
  exit 1
fi

echo "PASS: NIS server is removed"
exit 0
