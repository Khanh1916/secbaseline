#!/bin/bash
if ! command -v sestatus &>/dev/null; then
	echo "fail: Lệnh 'sestatus' không tồn tại. Có thể SELinux chưa được cài đặt."
	exit 1
fi

policy_info=$(sestatus 2>/dev/null | grep "Loaded policy name:")

if [ -z "$policy_info" ]; then
	echo "fail: Không tìm thấy thông tin về chính sách SELinux đang load."
	exit 1
else
	echo "pass: SELinux đang sử dụng chính sách: $policy_info"
	exit 0
fi
