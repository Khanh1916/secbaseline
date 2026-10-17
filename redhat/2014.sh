#!/bin/bash

if ! findmnt /var/log &> /dev/null; then
  echo "/var/log partition is not configured."
  exit 1
fi

echo "/var/log partition is configured."
exit 0
