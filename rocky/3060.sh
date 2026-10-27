#!/bin/bash

# Reads the running values. IPv6 keys are skipped when the kernel runs
# without IPv6 (ipv6.disable=1), which leaves nothing to configure.
SETTINGS="net.ipv4.icmp_echo_ignore_broadcasts=1"

bad=""
for setting in $SETTINGS; do
  key=${setting%%=*}
  want=${setting#*=}
  case "$key" in
    net.ipv6.*) [ -d /proc/sys/net/ipv6 ] || continue ;;
  esac
  value=$(sysctl -n "$key" 2>/dev/null)
  echo "INFO: $key = ${value:-unreadable} (want $want)"
  [ "$value" = "$want" ] || bad="$bad $key"
done

if [ -n "$bad" ]; then
  echo "FAIL: Broadcast ICMP echo requests must be ignored; wrong:$bad"
  exit 1
fi

echo "PASS: Broadcast ICMP echo requests is ignored"
exit 0
