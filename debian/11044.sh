#!/bin/bash
samba_status=$(dpkg -s samba 2>&1)

if echo "$samba_status" | grep -q "Status: install ok installed"; then
	echo "fail: Gói samba đang được cài đặt."
	exit 1
else
	echo "pass: Gói samba không được cài đặt." 	
	exit 0
fi

