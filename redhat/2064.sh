#!/bin/bash

if rpm -q tcp_wrappers &> /dev/null; then
  echo "TCP Wrapper is installed."
  exit 0
fi

echo "TCP Wrapper is not installed."
exit 1
