#!/bin/bash
output=$(rpm -q xinetd)

echo "$output"

if [[ "$output" == "package xinetd is not installed" ]]; then
	    echo "PASS: xinetd is not installed"
	        exit 0
	else
		    echo "FAIL: xinetd is installed"
		        exit 1
fi

