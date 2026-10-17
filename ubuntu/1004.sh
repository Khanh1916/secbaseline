#!/bin/bash
output=$(df -h /tmp 2>&1)
if echo "$output" | grep -q "No such file or directory"; then
	echo "FAIL: /tmp does not exist or is not a separate mount"
	exit 1
elif echo "$output" | grep -q "^/"; then
	echo "PASS: /tmp is a separate filesystem"
	exit 0
else
	echo "FAIL: /tmp is not a separate filesystem"
	exit 1
fi
