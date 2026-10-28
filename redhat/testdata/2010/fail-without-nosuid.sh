#!/bin/bash
# /dev/shm is mounted without nosuid.
umount /dev/shm
mount -t tmpfs -o nodev,noexec tmpfs /dev/shm
