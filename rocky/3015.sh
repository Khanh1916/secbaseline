#!/bin/bash
output=$(findmnt /var/log/audit)

echo "$output"

if echo "$output" | grep -q "/var/log/audit"; then
	    echo "PASS: /var/log/audit is mounted"
	        exit 0
	else
		    echo "FAIL: /var/log/audit is not mounted"
		        exit 1
fi
