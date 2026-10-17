#!/bin/bash

if ! findmnt -l | grep /dev/shm | grep -q nodev; then
  echo "/dev/shm partition nodev option is not configured."
  exit 1
fi

echo "/dev/shm partition nodev option is configured."
exit 0
