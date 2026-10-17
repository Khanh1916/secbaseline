#!/bin/bash
check_output=$(dpkg -s aide 2>&1)

if echo "$check_output" | grep -q "Status: install ok installed"; then
	echo "PASS: Package aide is installed"
	exit 0
else
	if echo "$check_output" | grep -q "is not installed and no information is available"; then
	echo "FAIL: Package aide is not installed"
	exit 1
	else
		[ -n "$check_output" ] && echo "$check_output" | sed 's/^/INFO: /'
		echo "FAIL: Could not determine the status of package aide"
		exit 1
	fi
fi
