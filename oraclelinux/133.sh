#!/bin/bash

if rpm -q xinetd &> /dev/null; then
  echo "xinetd is installed."
  exit 1
fi

echo "xinetd is not installed."
exit 0
