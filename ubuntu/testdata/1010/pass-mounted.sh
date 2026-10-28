#!/bin/bash
# /dev/shm is mounted with nodev, nosuid and noexec.
umount /dev/shm
mount -t tmpfs -o nodev,nosuid,noexec tmpfs /dev/shm
