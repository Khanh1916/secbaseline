#!/bin/bash

# A login warning banner is configured: /etc/issue, shown before local logins,
# holds text of its own. The distribution's default identifies the system
# (getty escapes such as \S, \r and \m, or the distribution's name) and is not
# a warning.
ISSUE=/etc/issue

if [ ! -f "$ISSUE" ]; then
  echo "FAIL: $ISSUE does not exist"
  exit 1
fi

if ! grep -q '[[:alnum:]]' "$ISSUE"; then
  echo "FAIL: $ISSUE is empty"
  exit 1
fi

os_name=$(. /etc/os-release 2>/dev/null && printf '%s' "$NAME")
if grep -q '\\[mrsSv]' "$ISSUE" || { [ -n "$os_name" ] && grep -iqF "$os_name" "$ISSUE"; }; then
  head -n 5 "$ISSUE" | sed 's/^/INFO: /'
  echo "FAIL: $ISSUE identifies the system instead of holding a warning"
  exit 1
fi

echo "PASS: $ISSUE holds a login warning"
exit 0
