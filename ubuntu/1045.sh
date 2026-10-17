#!/bin/bash
squid_status=$(dpkg -s squid 2>&1)

if echo "$squid_status" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package squid is installed"
	exit 1
else
	echo "PASS: Package squid is not installed"
	exit 0
fi

