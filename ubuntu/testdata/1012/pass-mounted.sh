#!/bin/bash
# /var is a separate mount with an fstab entry.
mkdir -p /var
mount --bind /var /var
echo '/dev/mapper/vg0-var /var ext4 defaults 0 2' >>/etc/fstab
