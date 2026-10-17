#!/bin/bash
output=$(dpkg -s cups 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "pass: Gói cups không được cài đặt."
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "fail: Gói cups đang được cài đặt."
	exit 1
fi

echo "fail: Không xác định được trạng thái của gói cups."
exit 1
