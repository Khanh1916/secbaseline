#!/bin/bash

if ! findmnt -l | grep /tmp | grep -q nodev; then
  echo "/tmp partition nodev option is not configured."
  exit 1
fi

echo "/tmp partition nodev option is configured."
exit 0
