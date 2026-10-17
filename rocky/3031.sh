#!/bin/bash
output=$(timedatectl | grep "System clock synchronized")

echo "$output"

if echo "$output" | grep -q "yes"; then
	    echo "PASS: System clock is synchronized"
	        exit 0
	else
		    echo "FAIL: System clock is NOT synchronized"
		        exit 1
fi
