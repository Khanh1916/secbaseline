#!/bin/bash

if ! sestatus | grep "Current mode" | grep -q "enforcing"; then
  echo "SELinux is not in enforcing mode."
  exit 1
fi

echo "SELinux is in enforcing mode."
exit 0
