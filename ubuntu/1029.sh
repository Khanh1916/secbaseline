#!/bin/bash
banner_line=$(grep "^Banner" /etc/ssh/sshd_config 2>/dev/null)

if [ -z "$banner_line" ]; then
	echo "FAIL: #Banner none"
	exit 1
fi

banner_file=$(echo "$banner_line" | awk '{print $2}')

if [ -f "$banner_file" ]; then
	echo "PASS: pass"
	exit 0
else
	echo "FAIL: #Banner none"
	exit 1
fi

