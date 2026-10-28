#!/bin/bash
# /etc/issue.net names the operating system.
echo 'Authorized users only. All activity may be monitored and reported.' >/etc/issue
echo 'Authorized users only. All activity may be monitored and reported.' >/etc/issue.net
. /etc/os-release
echo "$NAME" >>/etc/issue.net
