#!/bin/bash
output=$(grep -i "Rocky" /etc/issue 2>/dev/null)

if [[ -z "$output" ]]; then
	    echo "PASS: Không có \"Rocky\" trong output"
	        exit 0
	else
		    echo "FAIL: \"Rocky\" có trong output"
		        exit 1
fi
