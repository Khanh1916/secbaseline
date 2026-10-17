#!/bin/bash
# Scan every local filesystem (network mounts are skipped by df --local; -xdev
# keeps each find on its own filesystem so nothing is scanned twice).
dirs=$(df --local -P 2>/dev/null | awk 'NR > 1 {print $6}' | while read -r mnt; do
  find "$mnt" -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null
done | sort -u)

if [ -n "$dirs" ]; then
  echo "$dirs" | head -n 20 | sed 's/^/INFO: /'
  echo "FAIL: Found $(echo "$dirs" | wc -l) world-writable directories without the sticky bit"
  exit 1
fi

echo "PASS: All world-writable directories on local filesystems have the sticky bit set"
exit 0
