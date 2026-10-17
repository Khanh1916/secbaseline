#!/bin/bash
output=$(timedatectl status 2>/dev/null)

ntp_enabled=$(echo "$output" | grep "NTP enabled:" | awk '{print $3}')
ntp_sync=$(echo "$output" | grep "NTP synchronized:" | awk '{print $3}')

if [ "$ntp_enabled" = "yes" ] && [ "$ntp_sync" = "yes" ]; then
	echo "pass: NTP enabled: yes, NTP synchronized: yes"
	exit 0
else
	echo "fail: NTP enabled: $ntp_enabled, NTP synchronized: $ntp_sync"
	exit 1
fi
