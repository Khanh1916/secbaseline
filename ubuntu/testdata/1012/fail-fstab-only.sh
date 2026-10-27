#!/bin/bash
# fstab has an entry for /var, but nothing is mounted there.
mkdir -p /var
echo '/dev/mapper/vg0-var /var ext4 noauto 0 2' >>/etc/fstab
