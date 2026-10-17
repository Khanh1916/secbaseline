#!/bin/bash

if ! findmnt -l | grep /dev/shm | grep -q noexec; then
  echo "/dev/shm partition noexec option is not configured."
  exit 1
fi

echo "/dev/shm partition noexec option is configured."
exit 0
