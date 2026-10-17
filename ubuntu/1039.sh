#!/bin/bash
output=$(dpkg -s slapd 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "PASS: Package slapd is not installed"
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package slapd is installed"
	exit 1
fi

echo "FAIL: Could not determine the status of package slapd"
exit 1
