#!/bin/bash
mount_info=$(mount | grep " on /dev/shm ")
if [ -z "$mount_info" ]; then
	echo "FAIL: /dev/shm is not mounted or does not exist"
	exit 1
fi
if echo "$mount_info" | grep -q "nodev"; then
	echo "PASS: /dev/shm is mounted with the nodev option"
	exit 0
else
	echo "FAIL: /dev/shm is not mounted with the nodev option"
	exit 1
fi
