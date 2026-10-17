#!/bin/bash
output=$(systemctl is-enabled avahi-daemon 2>&1)

echo "$output"

if [[ "$output" == "disabled" || "$output" == *"not found"* ]]; then
	    echo "PASS: avahi-daemon is disabled or not found"
	        exit 0
	else
		    echo "FAIL: avahi-daemon is enabled"
		        exit 1
fi

