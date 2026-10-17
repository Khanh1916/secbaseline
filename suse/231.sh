#!/bin/bash

if ! systemctl is-enabled chronyd &> /dev/null; then
  echo "chronyd service is not enabled."
  exit 1
fi

echo "chronyd service is enabled."
exit 0
