#!/bin/bash

# Passes when one of these units is enabled (the unit name differs between
# distributions; aliases report "alias", so the real names are listed).
UNITS="ntpsec.service ntpd.service ntp.service"

for unit in $UNITS; do
  state=$(systemctl is-enabled "$unit" 2>/dev/null)
  echo "INFO: $unit: ${state:-not-found}"
  case "$state" in
    enabled | enabled-runtime)
      echo "PASS: ntp is enabled ($unit)"
      exit 0
      ;;
  esac
done

echo "FAIL: ntp is not installed or not enabled"
exit 1
