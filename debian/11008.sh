#!/bin/bash
output=$(df -h /dev/shm 2>&1)
if echo "$output" | grep -q "No such file or directory"; then
	echo "fail: /dev/shm không tồn tại hoặc chưa được cấu hình."
	exit 1
fi
if echo "$output" | grep -E "^(/|tmpfs)" > /dev/null; then
	echo "pass: /dev/shm là một filesystem riêng biệt."
	exit 0
else
	echo "fail: /dev/shm không phải là một filesystem riêng biệt."
	exit 1
fi
