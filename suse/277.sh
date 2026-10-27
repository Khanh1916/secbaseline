#!/bin/bash

# Log files under /var/log must not be writable by their group or accessible
# to others (0640 or stricter). wtmp, btmp and lastlog, written through the
# utmp group and read by tools such as last, may be 0664.
bad=$(find /var/log -type f \( \( -name 'wtmp*' -o -name 'btmp*' -o -name 'lastlog*' \) -perm /0113 \
  -o ! \( -name 'wtmp*' -o -name 'btmp*' -o -name 'lastlog*' \) -perm /0137 \) -printf '%m %p\n' 2>/dev/null)

if [ -n "$bad" ]; then
  echo "$bad" | head -n 20 | sed 's/^/INFO: /'
  echo "FAIL: $(echo "$bad" | wc -l) log files under /var/log are writable by their group or accessible to others"
  exit 1
fi

echo "PASS: Log files under /var/log are 0640 or stricter (0664 for wtmp, btmp and lastlog)"
exit 0
