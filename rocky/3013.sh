#!/bin/bash
output=$(findmnt /var/tmp)

echo "$output"

if echo "$output" | grep -q "/tmp"; then
	    echo "PASS: /var/tmp is bind mounted to /tmp"
	        exit 0
	else
		    echo "FAIL: /var/tmp is not bind mounted to /tmp"
		        exit 1
fi
