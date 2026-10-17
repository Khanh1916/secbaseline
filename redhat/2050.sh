#!/bin/bash

if rpm -q ypbind &> /dev/null; then
  echo "FAIL: NIS Client is available"
  exit 1
fi

echo "PASS: NIS Client is removed"
exit 0
