#!/bin/bash
output=$(sestatus | grep "Current mode")

echo "$output"

mode=$(echo "$output" | awk '{print $3}')

if [[ "$mode" == "enforcing" ]]; then
	    echo "PASS: SELinux current mode is enforcing"
	        exit 0
	else
		    echo "FAIL: SELinux current mode is not enforcing"
		        exit 1
fi
