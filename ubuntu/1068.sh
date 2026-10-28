#!/bin/bash

# ufw must start at boot (ufw.service enabled) and be active now (ufw status).
if ! command -v ufw >/dev/null 2>&1; then
  echo "FAIL: ufw is not installed"
  exit 1
fi

state=$(systemctl is-enabled ufw.service 2>/dev/null)
status=$(ufw status 2>/dev/null | awk 'NR == 1 {print $2}')
echo "INFO: ufw.service: ${state:-not-found}; ufw status: ${status:-unknown}"

if [ "$state" = enabled ] && [ "$status" = active ]; then
  echo "PASS: ufw is enabled and active"
  exit 0
fi

echo "FAIL: ufw is not enabled and active"
exit 1
