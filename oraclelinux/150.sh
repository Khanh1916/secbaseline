#!/bin/bash

if rpm -q rsh &> /dev/null; then
  echo "rsh service is available."
  exit 1
fi

echo "rsh is not installed."
exit 0
