#!/bin/bash
output=$(rpm -q libselinux)

echo "$output"

if [[ "$output" == libselinux* ]]; then
	    echo "PASS: libselinux is installed"
	        exit 0
	else
		    echo "FAIL: libselinux is not installed"
		        exit 1
fi
