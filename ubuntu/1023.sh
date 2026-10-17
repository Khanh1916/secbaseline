#!/bin/bash
if ! command -v sestatus &>/dev/null; then
	echo "fail: Lệnh 'sestatus' không tồn tại. Có thể SELinux chưa được cài đặt."
	exit 1
fi

selinux_status=$(sestatus 2>/dev/null | grep "SELinux status:")

if echo "$selinux_status" | grep -q "enabled"; then
	echo "pass: SELinux đã được cài đặt và bật (SELinux status: enabled)."
	exit 0
else
	echo "fail: SELinux đã được cài đặt nhưng đang bị tắt (SELinux status: disabled)."
	exit 1
fi

