#!/bin/bash
dovecot_status=$(dpkg -s dovecot-core 2>&1)

if echo "$dovecot_status" | grep -q "Status: install ok installed"; then
	echo "fail: Gói dovecot-core đang được cài đặt."
	exit 1
else
	echo "pass: Gói dovecot-core không được cài đặt."
	exit 0
fi

