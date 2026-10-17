#!/bin/bash
output=$(dpkg -s mcstran 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "pass: Gói mcstran không được cài đặt."
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "fail: Gói mcstran đang được cài đặt."
	exit 1
fi

echo "fail: Không xác định được trạng thái gói mcstran."
exit 1
