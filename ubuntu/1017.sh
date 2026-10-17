#!/bin/bash
mount_info=$(mount | grep " on /home ")

if [ -z "$mount_info" ]; then
	echo "fail: /home chưa được mount hoặc không tồn tại."
	exit 1
fi

if echo "$mount_info" | grep -qw "nodev"; then
	echo "pass: /home được mount với tùy chọn nodev."
	exit 0
else
	echo "fail: /home chưa được mount với tùy chọn nodev."
	exit 1
fi

