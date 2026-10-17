#!/bin/bash

if ! findmnt /var/log/audit &> /dev/null; then
  echo "/var/log/audit partition is not configured."
  exit 1
fi

echo "/var/log/audit partition is configured."
exit 0
