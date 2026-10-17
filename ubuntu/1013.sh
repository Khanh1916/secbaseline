#!/bin/bash
ls_output=$(ls -ld /var/tmp 2>&1)

if echo "$ls_output" | grep -q "No such file or directory"; then
	echo "fail: /var/tmp không tồn tại."
	exit 1
fi

if echo "$ls_output" | grep -qE "^l.* /var/tmp -> /tmp$"; then
	echo "pass: /var/tmp là symlink trỏ tới /tmp."
	echo "$ls_output"
	exit 0
else
	echo "fail: /var/tmp không phải là symlink trỏ tới /tmp."
	echo "$ls_output"
	exit 1
fi
