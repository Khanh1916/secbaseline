#!/bin/bash
output=$(findmnt -l | grep /dev/shm | grep nodev)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: /dev/shm is mounted with nodev"
	        exit 0
	else
		    echo "FAIL: /dev/shm is not mounted with nodev"
		        exit 1
fi
