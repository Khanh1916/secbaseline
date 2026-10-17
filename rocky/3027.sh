#!/bin/bash
output=$(rpm -q setroubleshoot)

echo "$output"

if [[ "$output" == "package setroubleshoot is not installed" ]]; then
	    echo "PASS: setroubleshoot is not installed"
	        exit 0
	else
		    echo "FAIL: setroubleshoot is installed"
		        exit 1
fi
