#!/bin/bash
output=$(sestatus | grep "SELinux status")

echo "$output"

status=$(echo "$output" | awk '{print $3}')

if [[ "$status" == "enabled" ]]; then
	    echo "PASS: SELinux status is enabled"
	        exit 0
	else
		    echo "FAIL: SELinux status is disabled"
		        exit 1
fi
