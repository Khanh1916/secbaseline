#!/bin/bash

# SELinux must be enforcing, both now (getenforce) and at the next boot
# (SELINUX= in /etc/selinux/config).
CONFIG=/etc/selinux/config
MODES="enforcing"

if ! command -v getenforce >/dev/null 2>&1; then
  echo "FAIL: getenforce not found; SELinux is not installed"
  exit 1
fi

current=$(getenforce 2>/dev/null | tr 'A-Z' 'a-z')
configured=$(awk -F= '/^[[:space:]]*SELINUX[[:space:]]*=/ {v = $2} END {gsub(/[[:space:]"]/, "", v); print tolower(v)}' "$CONFIG" 2>/dev/null)
echo "INFO: getenforce: ${current:-unknown}; $CONFIG: SELINUX=${configured:-unset}"

case " $MODES " in
  *" ${current:-none} "*) ;;
  *)
    echo "FAIL: SELinux is ${current:-not running}; it must be enforcing"
    exit 1
    ;;
esac

case " $MODES " in
  *" ${configured:-none} "*) ;;
  *)
    echo "FAIL: $CONFIG sets SELINUX=${configured:-nothing}; it must be enforcing"
    exit 1
    ;;
esac

echo "PASS: SELinux is $current and configured as $configured"
exit 0
