#!/bin/bash

if rpm -q mcstrans &>/dev/null; then
  echo "mcstrans is installed."
  exit 1
fi

echo "mcstrans is not installed."
exit 0
