#!/bin/bash

if rpm -q xorg-x11-server-common &> /dev/null; then
  echo "xorg-x11-server-common is installed."
  exit 1
fi

echo "xorg-x11-server-common is not installed."
exit 0
