#!/bin/bash
mount_info=$(mount | grep " on /tmp ")
if [ -z "$mount_info" ]; then
	echo "fail: /tmp chưa được mount hoặc không tồn tại."
	exit 1
fi
if echo "$mount_info" | grep -q "nosuid"; then
	echo "pass: /tmp đã được mount với tùy chọn nosuid."
	exit 0
else
	echo "fail: /tpm chưa được mount với tùy chon nosuid"
	exit 1
fi
