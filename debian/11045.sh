#!/bin/bash
squid_status=$(dpkg -s squid 2>&1)

if echo "$squid_status" | grep -q "Status: install ok installed"; then
	echo "fail: Gói squid đang được cài đặt."
	exit 1
else
	echo "pass: Gói squid không được cài đặt."
	exit 0
fi

