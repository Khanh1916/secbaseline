#!/bin/bash
if ! systemctl list-unit-files | grep -q "^ntp.service"; then
	echo "FAIL: Unit ntp.service could not be found"
	exit 1
fi
is_active=$(systemctl is-active ntp 2>/dev/null)
is_enabled=$(systemctl is-enabled ntp 2>/dev/null)

if [ "$is_active" = "active" ] && [ "$is_enabled" = "enabled" ]; then
	echo "PASS: Service ntp is running and enabled"
	exit 0
else
	echo "FAIL: Service ntp is not running and enabled (active: $is_active, enabled: $is_enabled)"
	exit 1
fi

