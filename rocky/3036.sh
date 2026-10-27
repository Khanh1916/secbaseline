#!/bin/bash

# Fails when any of these units is enabled or running: a socket or path unit
# starts the service on demand even when the service itself is disabled.
# Missing, disabled and masked units pass.
UNITS="avahi-daemon.service avahi-daemon.socket"

bad=""
for unit in $UNITS; do
  state=$(systemctl is-enabled "$unit" 2>/dev/null)
  echo "INFO: $unit: ${state:-not-found}"
  case "$state" in
    enabled | enabled-runtime) bad="$bad $unit" ;;
  esac
  if systemctl is-active --quiet "$unit" 2>/dev/null; then
    bad="$bad $unit(active)"
  fi
done

if [ -n "$bad" ]; then
  echo "FAIL: The Avahi server is enabled:$bad"
  exit 1
fi

echo "PASS: The Avahi server is not enabled"
exit 0
