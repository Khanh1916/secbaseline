#!/bin/bash
vsftpd_status=$(dpkg -s vsftpd 2>&1)
proftpd_status=$(dpkg -s proftpd-basic 2>&1)
pureftpd_status=$(dpkg -s pure-ftpd 2>&1)

if echo "$vsftpd_status" | grep -q "Status: install ok installed" || \
	echo "$proftpd_status" | grep -q "Status: install ok installed" || \
	echo "$pureftpd_status" | grep -q "Status: install ok installed"; then
	echo "fail: Một trong các gói FTP server đang được cài đặt."
	exit 1
else
	echo "pass: Các gói FTP server phổ biến không được cài đặt."
	exit 0
fi
