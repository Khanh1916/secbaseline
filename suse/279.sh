#!/bin/bash

if rpm -q audit &> /dev/null; then
  echo "Audit is installed."
  exit 0
fi

echo "Audit is not installed."
exit 1
