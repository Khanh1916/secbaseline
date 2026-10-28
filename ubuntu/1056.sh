#!/bin/bash

# Reads the running values. IPv6 keys are skipped when the kernel runs
# without IPv6 (ipv6.disable=1), which leaves nothing to configure.
SETTINGS="net.ipv4.conf.all.accept_redirects=0 net.ipv4.conf.default.accept_redirects=0 net.ipv6.conf.all.accept_redirects=0 net.ipv6.conf.default.accept_redirects=0"

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
  echo "FAIL: ICMP redirects must be rejected; wrong:$bad"
  exit 1
fi

echo "PASS: ICMP redirects is rejected"
exit 0
