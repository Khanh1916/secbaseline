#!/bin/bash

if rpm -q xorg-x11-server &> /dev/null; then
  echo "Package xorg-x11-server-common is installed."
  exit 1
fi

echo "Package xorg-x11-server-common is not installed."
exit 0
