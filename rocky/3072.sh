#!/bin/bash

protocol_config=$(grep "^Protocol" /etc/ssh/sshd_config 2>/dev/null)

if [ -n "$protocol_config" ] && echo "$protocol_config" | grep -q "Protocol 2"; then
  echo "Configured with Protocol 2."
  exit 0
fi

echo "Not configured or not Protocol 2."
exit 1
