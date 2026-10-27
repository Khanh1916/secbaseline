#!/bin/bash
# /dev/shm is a tmpfs mount.
umount /dev/shm
mount -t tmpfs -o nodev,nosuid,noexec tmpfs /dev/shm
