#!/bin/bash
output=$(dpkg -s isc-dhcp-server 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "pass: Gói isc-dhcp-server không được cài đặt."
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "fail: Gói isc-dhcp-server đang được cài đặt."
	exit 1
fi

echo "fail: Không xác định được trạng thái của gói isc-dhcp-server."
exit 1
