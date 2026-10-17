#!/bin/bash
output=$(systemctl is-enabled ntpd 2>/dev/null)

echo "$output"

if [[ "$output" == "enabled" ]]; then
	    echo "PASS: ntpd service is enabled"
	        exit 0
	else
		    echo "FAIL: ntpd service is not enabled or not found"
		        exit 1
fi

