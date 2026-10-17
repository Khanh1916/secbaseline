#!/bin/bash
output_httpd=$(rpm -q httpd)
output_nginx=$(rpm -q nginx)

echo "$output_httpd"
echo "$output_nginx"

if [[ "$output_httpd" == "package httpd is not installed" && "$output_nginx" == "package nginx is not installed" ]]; then
	    echo "PASS: httpd and nginx are not installed"
	        exit 0
	else
		    echo "FAIL: httpd or nginx is installed"
		        exit 1
fi

