#!/bin/bash

if ! findmnt -l | grep /home | grep -q nodev; then
  echo "/home partition nodev option is not configured."
  exit 1
fi

echo "/home partition nodev option is configured."
exit 0
