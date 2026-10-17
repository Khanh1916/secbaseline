#!/bin/bash

if rpm -q vsftpd &> /dev/null || rpm -q proftpd &> /dev/null || rpm -q pure-ftpd &> /dev/null; then
  echo "FTP server packages are installed."
  exit 1
fi

echo "FTP server packages are not installed."
exit 0
