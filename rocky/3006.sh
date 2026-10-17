#!/bin/bash
output=$(findmnt -l | grep /tmp | grep nosuid)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: /tmp is mounted with nosuid"
	        exit 0
	else
		    echo "FAIL: /tmp is not mounted with nosuid"
		        exit 1
fi
