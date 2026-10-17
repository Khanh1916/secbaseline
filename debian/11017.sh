#!/bin/bash
mount_info=$(mount | grep " on /home ")

if [ -z "$mount_info" ]; then
	echo "FAIL: /home is not mounted or does not exist"
	exit 1
fi

if echo "$mount_info" | grep -qw "nodev"; then
	echo "PASS: /home is mounted with the nodev option"
	exit 0
else
	echo "FAIL: /home is not mounted with the nodev option"
	exit 1
fi

