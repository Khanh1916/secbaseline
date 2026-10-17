#!/bin/bash
output=$(findmnt -l | grep /home | grep nodev)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: /home is mounted with nodev"
	        exit 0
	else
		    echo "FAIL: /home is not mounted with nodev"
		        exit 1
fi
