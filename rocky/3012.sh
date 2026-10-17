#!/bin/bash
output=$(findmnt /var)

echo "$output"

if echo "$output" | grep -q "/var"; then
	    echo "PASS: /var is configured"
	        exit 0
	else
		    echo "FAIL: /var is not configured"
		        exit 1
fi
