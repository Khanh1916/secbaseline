#!/bin/bash
output=$(dpkg -s slapd 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "pass: Gói slapd không được cài đặt."
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "fail: Gói slapd đang được cài đặt."
	exit 1
fi

echo "fail: Không xác định được trạng thái của gói slapd."
exit 1
