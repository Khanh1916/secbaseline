#!/bin/bash

if ! dpkg -s auditd &> /dev/null; then
  echo "FAIL: package 'auditd' is not installed and no information is available"
  exit 1
fi

if ! dpkg -s audispd-plugins &> /dev/null; then
  echo "FAIL: package 'audispd-plugins' is not installed and no information is available"
  exit 1
fi

echo "PASS: auditd and audispd-plugins packages are installed"
exit 0
