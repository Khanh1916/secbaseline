#!/bin/bash

if rpm -q samba &> /dev/null; then
  echo "samba package is installed."
  exit 1
fi

echo "package samba is not installed."
exit 0
