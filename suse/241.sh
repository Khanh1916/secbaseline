#!/bin/bash

if ! rpm -q apache2 &>/dev/null && ! rpm -q nginx &>/dev/null; then
  echo "PASS: package httpd is not installed and package nginx is not installed"
  exit 0
else
  echo "FAIL: httpd or nginx is installed"
  exit 1
fi
