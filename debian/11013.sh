#!/bin/bash
ls_output=$(ls -ld /var/tmp 2>&1)

if echo "$ls_output" | grep -q "No such file or directory"; then
	echo "FAIL: /var/tmp does not exist"
	exit 1
fi

if echo "$ls_output" | grep -qE "^l.* /var/tmp -> /tmp$"; then
	[ -n "$ls_output" ] && echo "$ls_output" | sed 's/^/INFO: /'
	echo "PASS: /var/tmp is a symlink to /tmp"
	exit 0
else
	[ -n "$ls_output" ] && echo "$ls_output" | sed 's/^/INFO: /'
	echo "FAIL: /var/tmp is not a symlink to /tmp"
	exit 1
fi
