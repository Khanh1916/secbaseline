#!/bin/bash
output=$(findmnt /tmp)

echo "$output"

if echo "$output" | grep -q "/tmp"; then
	    echo "PASS: /tmp is mounted"
	        exit 0
	else
		    echo "FAIL: /tmp is not mounted"
		        exit 1
fi

