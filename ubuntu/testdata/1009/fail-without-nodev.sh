#!/bin/bash
# /dev/shm is mounted without nodev.
umount /dev/shm
mount -t tmpfs -o nosuid,noexec tmpfs /dev/shm
