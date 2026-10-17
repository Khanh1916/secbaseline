#!/bin/bash
dirs=$(find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null)

if [ -z "$dirs" ]; then
	echo "pass: Không có thư mục world-writable nào thiếu sticky bit."
	exit 0
else
	echo "fail: Các thư mục world-writable chưa có sticky bit:"
	echo "$dirs"
	exit 1
fi
