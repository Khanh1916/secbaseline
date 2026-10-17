#!/bin/bash

if rpm -q talk-server &> /dev/null; then
  echo "talk-server is installed."
  exit 1
fi

echo "talk-server is not installed."
exit 0
