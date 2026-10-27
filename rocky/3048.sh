#!/bin/bash

# CIS: the MTA accepts mail only from the local host. Passes when nothing
# listens on the SMTP ports (25, 465, 587) on a non-loopback address, which is
# also the case when no MTA is installed. Postfix's inet_interfaces is checked
# as well, so a stopped Postfix that would listen on all interfaces still fails.
MAIL_PORTS="25 465 587"

if ! listeners=$(ss -lnt 2>/dev/null); then
  echo "FAIL: Cannot list listening TCP sockets with ss"
  exit 1
fi

exposed=""
while read -r local_addr; do
  port=${local_addr##*:}
  case " $MAIL_PORTS " in
    *" $port "*) ;;
    *) continue ;;
  esac
  addr=${local_addr%:*}
  addr=${addr#[}
  addr=${addr%]}
  addr=${addr%%\%*}
  case "$addr" in
    127.*|::1|::ffff:127.*) echo "INFO: Port $port listens on loopback address $addr" ;;
    *) exposed="$exposed $local_addr" ;;
  esac
done < <(echo "$listeners" | awk 'NR > 1 {print $4}')

if command -v postconf >/dev/null 2>&1; then
  inet_interfaces=$(postconf -h inet_interfaces 2>/dev/null)
  echo "INFO: postfix inet_interfaces = $inet_interfaces"
  for iface in $(echo "$inet_interfaces" | tr ',' ' '); do
    case "$iface" in
      localhost|loopback-only|127.0.0.1|'[::1]'|::1) ;;
      *) exposed="$exposed postfix:inet_interfaces=$iface" ;;
    esac
  done
fi

if [ -n "$exposed" ]; then
  echo "FAIL: MTA must listen only on loopback (ports $MAIL_PORTS); found:$exposed"
  exit 1
fi

echo "PASS: No MTA listens on a non-loopback address (ports $MAIL_PORTS)"
exit 0
