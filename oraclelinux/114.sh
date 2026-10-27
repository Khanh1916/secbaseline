#!/bin/bash

# /var/log/audit must be a mount of its own (a partition, a logical volume or a tmpfs), not
# a directory on the filesystem above it. findmnt -k reads the kernel's mount
# table, so only what is mounted now counts, not what /etc/fstab lists.
info=$(findmnt -kn -o SOURCE,FSTYPE,OPTIONS /var/log/audit 2>/dev/null)

if [ -z "$info" ]; then
  echo "FAIL: /var/log/audit is not a separate mount"
  exit 1
fi

echo "$info" | sed 's|^|INFO: /var/log/audit: |'
echo "PASS: /var/log/audit is a separate mount"
exit 0
