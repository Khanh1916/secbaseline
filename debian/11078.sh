#!/bin/bash

if auditctl -s 2>/dev/null | grep -q "enabled 1" && auditctl -s 2>/dev/null | grep -q "immutable 1" && auditctl -l 2>/dev/null | grep -q "."; then
  echo "Auditing is enabled with immutable=1 and audit rules are configured."
  exit 0
fi

echo "Auditing is not properly configured (enabled!=1, immutable!=1, or no audit rules)."
exit 1
