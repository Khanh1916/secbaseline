#!/bin/bash
if ! systemctl list-units --type=service | grep -q "chronyd.service"; then
	echo "FAIL: Service chronyd is not installed"
	exit 1
fi

is_active=$(systemctl is-active chronyd 2>/dev/null)
is_enabled=$(systemctl is-enabled chronyd 2>/dev/null)

if [ "$is_active" = "active" ] && [ "$is_enabled" = "enabled" ]; then
	echo "PASS: Service chronyd is running and enabled"
	exit 0
else
	echo "FAIL: Service chronyd is not running and enabled (active: $is_active, enabled: $is_enabled)"
	exit 1
fi
