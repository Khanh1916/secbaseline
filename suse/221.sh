#!/bin/bash

if rpm -q prelink &>/dev/null; then
  echo "prelink is installed."
  exit 1
fi

echo "prelink is not installed."
exit 0
