#!/bin/bash

if systemctl is-enabled cups &> /dev/null; then
  echo "cups is enabled."
  exit 1
fi

echo "cups is not enabled."
exit 0
