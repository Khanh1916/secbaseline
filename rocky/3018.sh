#!/bin/bash
output=$(find / -type d -perm -0002 ! -perm -1000 2>/dev/null)

echo "$output"

if [[ -z "$output" ]]; then
	    echo "PASS: No world-writable directories without sticky bit"
	        exit 0
	else
		    echo "FAIL: The following world-writable directories lack sticky bit:"
		        echo "$output"
			    exit 1
fi
