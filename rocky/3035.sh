#!/bin/bash
output=$(rpm -q xorg-x11-server-common)

echo "$output"

if [[ "$output" == "package xorg-x11-server-common is not installed" ]]; then
	    echo "PASS: xorg-x11-server-common is not installed"
	        exit 0
	else
		    echo "FAIL: xorg-x11-server-common is installed"
		        exit 1
fi

