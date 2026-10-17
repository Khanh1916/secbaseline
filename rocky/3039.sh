#!/bin/bash
output=$(rpm -q slapd)

echo "$output"

if [[ "$output" == "package slapd is not installed" ]]; then
	    echo "PASS: slapd is not installed"
	        exit 0
	else
		    echo "FAIL: slapd is installed"
		        exit 1
fi
