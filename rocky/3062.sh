#!/bin/bash

# Reads the running values. IPv6 keys are skipped when the kernel runs
# without IPv6 (ipv6.disable=1), which leaves nothing to configure.
SETTINGS="net.ipv4.conf.all.rp_filter=1 net.ipv4.conf.default.rp_filter=1"

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
  echo "FAIL: Strict reverse path filtering must be enabled; wrong:$bad"
  exit 1
fi

echo "PASS: Strict reverse path filtering is enabled"
exit 0
