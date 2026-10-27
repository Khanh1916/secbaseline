#!/bin/bash

# Reads the running values. IPv6 keys are skipped when the kernel runs
# without IPv6 (ipv6.disable=1), which leaves nothing to configure.
SETTINGS="net.ipv4.conf.all.accept_source_route=0 net.ipv4.conf.default.accept_source_route=0 net.ipv6.conf.all.accept_source_route=0 net.ipv6.conf.default.accept_source_route=0"

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
  echo "FAIL: Source-routed packets must be rejected; wrong:$bad"
  exit 1
fi

echo "PASS: Source-routed packets is rejected"
exit 0
