#!/bin/bash
if ! command -v getenforce &> /dev/null; then
	echo "fail: Command 'getenforce' not found. Có thể SELinux chưa được cài đặt."
	exit 1
fi

selinux_status=$(getenforce)

if [ "$selinux_status" == "Enforcing" ]; then
	echo "pass: SELinux đang ở chế độ Enforcing."
	exit 0
else
	echo "fail: SELinux đang ở chế độ $selinux_status. Yêu cầu cấu hình lại."
	exit 1
fi

