#!/bin/bash
bind9_status=$(dpkg -s bind9 2>&1)
unbound_status=$(dpkg -s unbound 2>&1)

if echo "$bind9_status" | grep -q "Status: install ok installed" || echo "$unbound_status" | grep -q "Status: install ok installed"; then
	echo "FAIL: Package bind9 or unbound is installed"
	exit 1
else
	echo "PASS: Packages bind9 and unbound are not installed"
	exit 0
fi

