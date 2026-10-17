#!/bin/bash

if rpm -q telnet-server &> /dev/null; then
  echo "Telnet server is available."
  exit 1
fi

echo "Telnet server is removed."
exit 0
