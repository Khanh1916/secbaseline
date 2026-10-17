#!/bin/bash
output=$(dpkg -s avahi-daemon 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "PASS: Package avahi-daemon is not installed"
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package avahi-daemon is installed"
	exit 1
fi

echo "FAIL: Could not determine the status of package avahi-daemon"
exit 1
