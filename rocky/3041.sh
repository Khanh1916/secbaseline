#!/bin/bash
output_vsftpd=$(rpm -q vsftpd)
output_proftpd=$(rpm -q proftpd)
output_pureftpd=$(rpm -q pure-ftpd)

echo "$output_vsftpd"
echo "$output_proftpd"
echo "$output_pureftpd"

if [[ "$output_vsftpd" == "package vsftpd is not installed" && \
	      "$output_proftpd" == "package proftpd is not installed" && \
	            "$output_pureftpd" == "package pure-ftpd is not installed" ]]; then
    echo "PASS: All FTP servers are not installed"
        exit 0
else
	    echo "FAIL: At least one FTP server is installed"
	        exit 1
fi

