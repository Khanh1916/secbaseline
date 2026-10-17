#!/bin/bash
vsftpd_status=$(dpkg -s vsftpd 2>&1)
proftpd_status=$(dpkg -s proftpd-basic 2>&1)
pureftpd_status=$(dpkg -s pure-ftpd 2>&1)

if echo "$vsftpd_status" | grep -q "Status: install ok installed" || \
	echo "$proftpd_status" | grep -q "Status: install ok installed" || \
	echo "$pureftpd_status" | grep -q "Status: install ok installed"; then
	echo "FAIL: An FTP server package is installed"
	exit 1
else
	echo "PASS: No common FTP server package is installed"
	exit 0
fi
