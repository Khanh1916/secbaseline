#!/bin/bash
# /var/log/audit is a separate mount with an fstab entry.
mkdir -p /var/log/audit
mount --bind /var/log/audit /var/log/audit
echo '/dev/mapper/vg0-audit /var/log/audit ext4 defaults 0 2' >>/etc/fstab
