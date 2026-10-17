#!/bin/bash
dirs=$(find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null)

if [ -z "$dirs" ]; then
	echo "PASS: No world-writable directories without the sticky bit"
	exit 0
else
	[ -n "$dirs" ] && echo "$dirs" | sed 's/^/INFO: /'
	echo "FAIL: Found world-writable directories without the sticky bit"
	exit 1
fi
