#!/bin/bash
output=$(findmnt -l | grep /tmp | grep noexec)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: /tmp is mounted with noexec"
	        exit 0
	else
		    echo "FAIL: /tmp is not mounted with noexec"
		        exit 1
fi
