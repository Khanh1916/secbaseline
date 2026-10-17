#!/bin/bash

if [ ! -f /etc/audit/audit.rules ]; then
  echo "File empty or only comments"
  exit 1
fi

audit_rules=$(grep -E '^ *[^#]' /etc/audit/audit.rules 2>/dev/null)

if [ -n "$audit_rules" ]; then
  echo "Audit rules exist"
  exit 0
fi

echo "File empty or only comments"
exit 1
