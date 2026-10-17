#!/bin/bash
output=$(df -h /tmp 2>&1)
if echo "$output" | grep -q "No such file or directory"; then
	echo "/tmp không tồn tại hoặc chưa được mount riêng biệt."
	exit 1
elif echo "$output" | grep -q "^/"; then
	echo "/tmp là một filesystem riêng biệt."
	exit 0
else
	echo "/tmp không phải là một filesystem riêng biệt."
	exit 1
fi
