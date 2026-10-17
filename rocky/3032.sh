#!/bin/bash
output=$(systemctl is-enabled chronyd 2>/dev/null)

echo "$output"

if [[ "$output" == "enabled" ]]; then
	    echo "PASS: chronyd service is enabled"
	        exit 0
	else
		    echo "FAIL: chronyd service is not enabled or not found"
		        exit 1
fi

