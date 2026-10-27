#!/bin/bash
# /dev/shm is a tmpfs mount whose source is "none", as in older fstab files.
umount /dev/shm
mount -t tmpfs -o nodev,nosuid,noexec none /dev/shm
