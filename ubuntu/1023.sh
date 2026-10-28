#!/bin/bash

# SELinux is installed when its tools are: sestatus (policycoreutils) and
# getenforce (selinux-utils). Whether it is enabled is checked separately.
missing=""
for cmd in sestatus getenforce; do
  command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done

if [ -n "$missing" ]; then
  echo "FAIL: SELinux tools are not installed; missing:$missing"
  exit 1
fi

echo "PASS: SELinux tools are installed (sestatus, getenforce)"
exit 0
