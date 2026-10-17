#!/bin/bash
output=$(rpm -q samba)

echo "$output"

if [[ "$output" == "package samba is not installed" ]]; then
	    echo "PASS: samba is not installed"
	        exit 0
	else
		    echo "FAIL: samba is installed"
		        exit 1
fi

