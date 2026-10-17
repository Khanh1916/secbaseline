#!/bin/bash
output=$(sestatus | grep "SELinux mode")

echo "$output"

mode=$(echo "$output" | awk '{print $3}')

if [[ "$mode" == "enforcing" || "$mode" == "permissive" ]]; then
	    echo "PASS: SELinux mode is $mode"
	        exit 0
	else
		    echo "FAIL: SELinux mode is $mode"
		        exit 1
fi
