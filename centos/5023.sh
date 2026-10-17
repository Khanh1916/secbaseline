#!/bin/bash

if ! rpm -q libselinux &> /dev/null; then
  echo "libselinux is not installed."
  exit 1
fi

echo "libselinux is installed."
exit 0
