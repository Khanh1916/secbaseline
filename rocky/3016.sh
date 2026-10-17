#!/bin/bash
output=$(findmnt /home)

echo "$output"

if echo "$output" | grep -q "/home"; then
	    echo "PASS: /home is mounted"
	        exit 0
	else
		    echo "FAIL: /home is not mounted"
		        exit 1
fi
