#!/bin/bash
output=$(findmnt -l | grep /dev/shm | grep nosuid)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: /dev/shm is mounted with nosuid"
	        exit 0
	else
		    echo "FAIL: /dev/shm is not mounted with nosuid"
		        exit 1
fi
