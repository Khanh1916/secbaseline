#!/bin/bash

if [ -f /etc/hosts.deny ] && cat /etc/hosts.deny | grep -qw "ALL: ALL"; then
  echo "/etc/hosts.deny exists and contains 'ALL: ALL' rule."
  exit 0
else
  echo "/etc/hosts.deny does not exist or does not contain 'ALL: ALL' rule."
  exit 1
fi
