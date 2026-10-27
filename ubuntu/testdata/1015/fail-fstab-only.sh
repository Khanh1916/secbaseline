#!/bin/bash
# fstab has an entry for /var/log/audit, but nothing is mounted there.
mkdir -p /var/log/audit
echo '/dev/mapper/vg0-audit /var/log/audit ext4 noauto 0 2' >>/etc/fstab
