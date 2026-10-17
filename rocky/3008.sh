#!/bin/bash
output=$(findmnt /dev/shm)

echo "$output"

if echo "$output" | grep -q "/dev/shm"; then
	    echo "PASS: /dev/shm is configured"
	        exit 0
	else
		    echo "FAIL: /dev/shm is not configured"
		        exit 1
fi
