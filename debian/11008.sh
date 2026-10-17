#!/bin/bash
output=$(df -h /dev/shm 2>&1)
if echo "$output" | grep -q "No such file or directory"; then
	echo "FAIL: /dev/shm does not exist or is not configured"
	exit 1
fi
if echo "$output" | grep -E "^(/|tmpfs)" > /dev/null; then
	echo "PASS: /dev/shm is a separate filesystem"
	exit 0
else
	echo "FAIL: /dev/shm is not a separate filesystem"
	exit 1
fi
