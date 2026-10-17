#!/bin/bash
dovecot_status=$(dpkg -s dovecot-core 2>&1)

if echo "$dovecot_status" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package dovecot-core is installed"
	exit 1
else
	echo "PASS: Package dovecot-core is not installed"
	exit 0
fi

