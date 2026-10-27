#!/bin/bash
# fstab has an entry for /home, but nothing is mounted there.
mkdir -p /home
echo '/dev/mapper/vg0-home /home ext4 noauto 0 2' >>/etc/fstab
