#!/bin/bash

if ! timedatectl | grep "System clock synchronized" | grep -q "yes"; then
  echo "FAIL: System clock is not synchronized"
  exit 1
fi

echo "PASS: System clock is synchronized"
exit 0
