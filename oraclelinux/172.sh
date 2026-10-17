#!/bin/bash

# Check SSH LogLevel configuration
loglevel_config=$(grep "^LogLevel" /etc/ssh/sshd_config 2>/dev/null)

if [ -n "$loglevel_config" ]; then
  if echo "$loglevel_config" | grep -q "LogLevel INFO" || echo "$loglevel_config" | grep -q "LogLevel VERBOSE"; then
    echo "SSH LogLevel is properly configured to INFO or VERBOSE."
    exit 0
  fi
fi

echo "SSH LogLevel is not set to INFO or VERBOSE."
exit 1
