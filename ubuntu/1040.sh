#!/bin/bash
bind9_status=$(dpkg -s bind9 2>&1)
unbound_status=$(dpkg -s unbound 2>&1)

if echo "$bind9_status" | grep -q "Status: install ok installed" || echo "$unbound_status" | grep -q "Status: install ok installed"; then
	echo "fail: Một trong các gói bind9 hoặc unbound đang được cài đặt."
	exit 1
else
	echo "pass: Các gói bind9 và unbound không được cài đặt."
	exit 0
fi

