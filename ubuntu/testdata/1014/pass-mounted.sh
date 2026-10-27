#!/bin/bash
# /var/log is a separate mount with an fstab entry.
mkdir -p /var/log
mount --bind /var/log /var/log
echo '/dev/mapper/vg0-log /var/log ext4 defaults 0 2' >>/etc/fstab
