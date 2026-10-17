#!/bin/bash
output=$(findmnt -l | grep /dev/shm | grep noexec)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: /dev/shm is mounted with noexec"
	        exit 0
	else
		    echo "FAIL: /dev/shm is not mounted with noexec"
		        exit 1
fi
