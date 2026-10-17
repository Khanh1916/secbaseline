#!/bin/bash

if ! grep -q "^[[:space:]]*LogLevel[[:space:]]\+\(INFO\|VERBOSE\)" /etc/ssh/sshd_config 2>/dev/null; then
  echo "SSH LogLevel is not set to INFO or VERBOSE"
  exit 1
fi

echo "SSH LogLevel is properly configured to INFO or VERBOSE"
exit 0
