#!/bin/bash

if ! findmnt /dev/shm &> /dev/null; then
 echo "/dev/shm partition is not configured."
 exit 1
fi

echo "/dev/shm partition is configured."
exit 0
