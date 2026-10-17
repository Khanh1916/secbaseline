#!/bin/bash
mount_info=$(mount | grep " on /dev/shm ")
if [ -z "$mount_info" ]; then
	echo "fail: /dev/shm chưa được mount hoặc không tồn tại."
	exit 1
fi
if echo "$mount_info" | grep -q "nodev"; then
	echo "pass: /dev/shm đã được mount với tùy chọn nodev."
	exit 0
else
	echo "fail: /dev/shm chưa được mount với tùy chọn nodev."
	exit 1
fi
