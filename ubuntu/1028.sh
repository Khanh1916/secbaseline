#!/bin/bash
output=$(dpkg -s mcstrans 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "PASS: Package mcstrans is not installed"
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package mcstrans is installed"
	exit 1
fi

echo "FAIL: Could not determine the status of package mcstrans"
exit 1
