#!/bin/bash
# fstab has an entry for /var/log, but nothing is mounted there.
mkdir -p /var/log
echo '/dev/mapper/vg0-log /var/log ext4 noauto 0 2' >>/etc/fstab
