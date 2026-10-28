#!/bin/bash

# Audit rules are configured when the files auditd loads at boot
# (/etc/audit/rules.d/*.rules, compiled by augenrules into
# /etc/audit/audit.rules) hold at least one watch (-w) or syscall rule (-a)
# that records events. Control lines such as -D, -b, -f and -e are not rules,
# and neither are never rules such as SUSE's default "-a task,never", which
# turns syscall auditing off.
count=0
for f in /etc/audit/audit.rules /etc/audit/rules.d/*.rules; do
  [ -f "$f" ] || continue
  n=$(awk '/^[[:space:]]*-w[[:space:]]/ || (/^[[:space:]]*-[aA][[:space:]]/ && !/never/) {n++} END {print n + 0}' "$f")
  echo "INFO: $f: $n rules"
  count=$((count + n))
done

if [ "$count" -eq 0 ]; then
  echo "FAIL: No audit rules are configured"
  exit 1
fi

echo "PASS: Audit rules are configured"
exit 0
