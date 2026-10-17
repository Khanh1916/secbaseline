#!/bin/bash

if ! timedatectl | grep "System clock synchronized" | grep -q "yes"; then
  echo "System clock is not synchronized."
  exit 1
fi

echo "System clock is synchronized."
exit 0
