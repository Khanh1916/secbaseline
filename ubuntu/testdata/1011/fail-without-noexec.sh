#!/bin/bash
# /dev/shm is mounted without noexec.
umount /dev/shm
mount -t tmpfs -o nodev,nosuid tmpfs /dev/shm
