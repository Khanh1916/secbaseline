#!/bin/bash
if ! systemctl list-units --type=service | grep -q "chronyd.service"; then
	echo "fail: Dịch vụ chronyd không được cài đặt."
	exit 1
fi

is_active=$(systemctl is-active chronyd 2>/dev/null)
is_enabled=$(systemctl is-enabled chronyd 2>/dev/null)

if [ "$is_active" = "active" ] && [ "$is_enabled" = "enabled" ]; then
	echo "pass: Dịch vụ chronyd đang chạy và được bật."
	exit 0
else
	echo "fail: Dịch vụ chronyd không hoạt động đúng (active: $is_active, enabled: $is_enabled)."
	exit 1
fi
