#!/bin/bash

if rpm -q httpd &> /dev/null || rpm -q nginx &> /dev/null; then
  echo "FAIL: HTTP server packages (apache2, nginx) are installed"
  exit 1
fi

echo "PASS: HTTP server packages (apache2, nginx) are not installed"
exit 0
