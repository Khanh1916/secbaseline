#!/bin/bash
samba_status=$(dpkg -s samba 2>&1)

if echo "$samba_status" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package samba is installed"
	exit 1
else
	echo "PASS: Package samba is not installed"
	exit 0
fi

