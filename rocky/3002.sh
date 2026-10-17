#!/bin/bash
output=$(modprobe -n -v squashfs)

echo "$output"

if [[ "$output" == "install /bin/true" ]]; then
	exit 0
else
	echo "module squashfs is not disabled properly"
	exit 1
fi
