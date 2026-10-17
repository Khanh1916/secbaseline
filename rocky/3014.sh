#!/bin/bash
output=$(findmnt /var/log)

echo "$output"

if echo "$output" | grep -q "/var/log"; then
	    echo "PASS: /var/log is mounted"
	        exit 0
	else
		    echo "FAIL: /var/log is not mounted"
		        exit 1
fi
