#!/bin/bash

if rpm -q aide &> /dev/null; then
  echo "AIDE is installed."
  exit 0
fi

echo "AIDE is not installed."
exit 1
