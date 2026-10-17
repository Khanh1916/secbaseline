#!/bin/bash
output=$(dpkg -s prelink 2>&1)

if echo "$output" | grep -q "is not installed and no information is available"; then
	echo "PASS: Package prelink is not installed"
	exit 0
fi

if echo "$output" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package prelink is installed"
	exit 1
fi

[ -n "$output" ] && echo "$output" | sed 's/^/INFO: /'
echo "FAIL: Could not determine the status of package prelink"
exit 1

