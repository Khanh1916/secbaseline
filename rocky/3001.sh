#!/bin/bash
output=$(modprobe -n -v cramfs)

if [[ "$output" == "install /bin/true" ]]; then
	echo "$output"
	exit 0
else
	echo "$output"
	exit 1
fi
