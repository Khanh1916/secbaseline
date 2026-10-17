#!/bin/bash
apache_status=$(dpkg -s apache2 2>&1)
nginx_status=$(dpkg -s nginx 2>&1)

if echo "$apache_status" | grep -q "Status: install ok installed" || \
	echo "$nginx_status" | grep -q "Status: install ok installed"; then
	echo "FAIL: An HTTP server package is installed"
	exit 1
else
	echo "PASS: No common HTTP server package is installed"
	exit 0
fi
