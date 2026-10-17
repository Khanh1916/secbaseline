#!/bin/bash
if ! systemctl list-unit-files | grep -q "^ntp.service"; then
	echo "fail: Unit ntp.service could not be found."
	exit 1
fi
is_active=$(systemctl is-active ntp 2>/dev/null)
is_enabled=$(systemctl is-enabled ntp 2>/dev/null)

if [ "$is_active" = "active" ] && [ "$is_enabled" = "enabled" ]; then
	echo "pass: Dịch vụ ntp đang chạy và được bật."
	exit 0
else
	echo "fail: Dịch vụ ntp không hoạt động đúng (active: $is_active, enabled: $is_enabled)."
	exit 1
fi

