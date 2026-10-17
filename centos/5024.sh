#!/bin/bash

if sestatus | grep "SELinux mode" | grep -q "disabled"; then
  echo "SELinux mode is disabled."
  exit 1
fi

echo "SELinux mode is Permissive or Enforcing."
exit 0
