#!/bin/bash
output=$(dpkg -s isc-dhcp-server 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "PASS: Package isc-dhcp-server is not installed"
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package isc-dhcp-server is installed"
	exit 1
fi

echo "FAIL: Could not determine the status of package isc-dhcp-server"
exit 1
