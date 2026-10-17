#!/bin/bash
output=$(rpm -q prelink)

echo "$output"

if [[ "$output" == "package prelink is not installed" ]]; then
	    echo "PASS: prelink is not installed"
	        exit 0
	else
		    echo "FAIL: prelink is installed"
		        exit 1
fi
