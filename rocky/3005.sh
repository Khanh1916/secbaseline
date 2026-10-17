#!/bin/bash
output=$(findmnt -l | grep /tmp | grep nodev)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: /tmp is mounted with nodev"
	        exit 0
	else
		    echo "FAIL: /tmp is not mounted with nodev"
		        exit 1
fi

