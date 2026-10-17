#!/bin/bash
output=$(dpkg -s avahi-daemon 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "pass: Gói avahi-daemon không được cài đặt."
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "fail: Gói avahi-daemon đang được cài đặt."
	exit 1
fi

echo "fail: Không xác định được trạng thái của gói avahi-daemon."
exit
