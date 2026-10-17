#!/bin/bash

if sestatus | grep "SELinux status" | grep -q "disabled"; then
  echo "SELinux status is disabled."
  exit 1
fi

echo "SELinux status is enabled."
exit 0
