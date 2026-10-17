#!/bin/bash

log_dir_perm=$(stat -c '%a' /var/log 2>/dev/null)
if [ "$log_dir_perm" != "640" ] && [ "$log_dir_perm" != "600" ]; then
  echo "/var/log directory permissions are not restrictive (current: $log_dir_perm, expected: 640 or 600)"
  exit 1
fi

if [ -f /var/log/syslog ]; then
  syslog_perm=$(stat -c '%a' /var/log/syslog 2>/dev/null)
  if [ "$syslog_perm" != "640" ] && [ "$syslog_perm" != "600" ]; then
    echo "/var/log/syslog file permissions are not restrictive (current: $syslog_perm, expected: 640 or 600)"
    exit 1
  fi
fi

if [ -f /var/log/auth.log ]; then
  authlog_perm=$(stat -c '%a' /var/log/auth.log 2>/dev/null)
  if [ "$authlog_perm" != "640" ] && [ "$authlog_perm" != "600" ]; then
    echo "/var/log/auth.log file permissions are not restrictive (current: $authlog_perm, expected: 640 or 600)"
    exit 1
  fi
fi

echo "Log directory and files have proper restrictive permissions"
exit 0
