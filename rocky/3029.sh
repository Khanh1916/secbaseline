#!/bin/bash
output=$(grep -i "banner" /etc/issue 2>/dev/null)

echo "$output"

if [[ -n "$output" ]]; then
	    echo "PASS: Banner cảnh báo có trong output"
	        exit 0
	else
		    echo "FAIL: Không có banner hoặc không có output"
		        exit 1
fi
