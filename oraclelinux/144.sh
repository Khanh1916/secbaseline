#!/bin/bash

if rpm -q squid &> /dev/null; then
  echo "squid package is installed."
  exit 1
fi

echo "package squid is not installed."
exit 0
