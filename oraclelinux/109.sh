#!/bin/bash

if ! findmnt -l | grep /dev/shm | grep -q nosuid; then
  echo "/dev/shm partition nosuid option is not configured."
  exit 1
fi

echo "/dev/shm partition nosuid option is configured."
exit 0
