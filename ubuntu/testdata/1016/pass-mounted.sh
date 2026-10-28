#!/bin/bash
# /home is a separate mount with an fstab entry.
mkdir -p /home
mount --bind /home /home
echo '/dev/mapper/vg0-home /home ext4 defaults 0 2' >>/etc/fstab
