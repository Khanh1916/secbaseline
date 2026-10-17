#!/bin/bash
output=$(dpkg -s setroubleshoot 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "pass: Gói setroubleshoot không được cài đặt."
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "fail: Gói setroubleshoot đang được cài đặt."
	exit 1
fi

echo "fail: Không xác định được trạng thái gói setroubleshoot."
exit 1

