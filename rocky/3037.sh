#!/bin/bash
output=$(systemctl is-enabled cups 2>&1)

echo "$output"

if [[ "$output" == "disabled" || "$output" == *"not found"* ]]; then
	    echo "PASS: cups service is disabled or not found"
	        exit 0
	else
		    echo "FAIL: cups service is enabled"
		        exit 1
fi
