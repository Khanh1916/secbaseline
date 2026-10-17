#!/bin/bash
mount_info=$(mount | grep " on /tmp ")
if [ -z "$mount_info" ]; then
	echo "FAIL: /tmp is not mounted or does not exist"
	exit 1
fi
if echo "$mount_info" | grep -q "noexec"; then
	echo "PASS: /tmp is mounted with the noexec option"
	exit 0
else
	echo "FAIL: /tmp is not mounted with the noexec option"
	exit 1
fi
