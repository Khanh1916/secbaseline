#!/bin/bash
apache_status=$(dpkg -s apache2 2>&1)
nginx_status=$(dpkg -s nginx 2>&1)

if echo "$apache_status" | grep -q "Status: install ok installed" || \
	echo "$nginx_status" | grep -q "Status: install ok installed"; then
	echo "fail: Một trong các gói HTTP server đang được cài đặt."
	exit 1
else
	echo "pass: Các gói HTTP server phổ biến không được cài đặt."
	exit 0
fi
