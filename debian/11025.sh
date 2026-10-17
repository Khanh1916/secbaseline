#!/bin/bash
if ! command -v getenforce &>/dev/null; then
	echo "fail: Lệnh 'getenforce' không tồn tại. Có thể SELinux chưa được cài đặt."
	exit 1
fi

selinux_mode=$(getenforce)

if [[ "$selinux_mode" == "Enforcing" || "$selinux_mode" == "Permissive" ]]; then
	echo "pass: SELinux đang ở chế độ $selinux_mode."
	exit 0
else
	echo "fail: SELinux đang ở chế độ $selinux_mode."
	exit 1
fi

