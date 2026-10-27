#!/bin/bash

# DESCRIPTION:
# This script validates Junos console and auxiliary port security in a
# configuration saved in set format ("show configuration | display set").
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Console port logs out on disconnect
# 3. Console port is insecure: entering single-user mode (password recovery)
#    then requires the root password
# 4. Auxiliary port is insecure or disabled
# 5. A statement that is deactivated ("deactivate system ports ...", or a
#    deactivated parent) does not count
#
# SAMPLE CONFIGURATION:
# set system ports console log-out-on-disconnect
# set system ports console insecure
# set system ports auxiliary insecure        (or: auxiliary disable)
#
# USAGE:
# ./8007.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: all required statements are present and active
# 1 - FAIL: a statement is missing or deactivated, or the file is unreadable

CONFIG="$1"
if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  # A statement is active when it is set and neither it nor a parent is deactivated.
  function active(stmt,   p) {
    if (!(stmt in set)) return 0
    for (p in off) if (stmt == p || index(stmt, p " ") == 1) return 0
    return 1
  }

  { sub(/[ \t\r]+$/, "") }
  /^set / { set[substr($0, 5)] = 1 }
  /^deactivate / { off[substr($0, 12)] = 1 }

  END {
    ok = active("system ports console log-out-on-disconnect") &&
         active("system ports console insecure") &&
         (active("system ports auxiliary insecure") || active("system ports auxiliary disable"))
    exit (ok ? 0 : 1)
  }
' "$CONFIG"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
