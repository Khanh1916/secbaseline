#!/bin/bash

# /var/log must be a mount of its own (a partition, a logical volume or a tmpfs), not
# a directory on the filesystem above it. findmnt -k reads the kernel's mount
# table, so only what is mounted now counts, not what /etc/fstab lists.
info=$(findmnt -kn -o SOURCE,FSTYPE,OPTIONS /var/log 2>/dev/null)

if [ -z "$info" ]; then
  echo "FAIL: /var/log is not a separate mount"
  exit 1
fi

echo "$info" | sed 's|^|INFO: /var/log: |'
echo "PASS: /var/log is a separate mount"
exit 0
