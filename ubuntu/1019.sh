#!/bin/bash
check_output=$(dpkg -s aide 2>&1)

if echo "$check_output" | grep -q "Status: install ok installed"; then
	echo "pass: Gói aide đã được cài đặt."
	exit 0
else
	if echo "$check_output" | grep -q "is not installed and no information is available"; then
	echo "fail: Gói aide chưa được cài đặt."
	exit 1
	else
		echo "fail: Không xác định được trạng thái gói aide."
		echo "$check_output"
		exit 1
	fi
fi
