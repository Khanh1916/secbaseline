#!/bin/bash

PACKAGES="tcpd"

# A package counts as installed unless dpkg knows it only by its leftover
# configuration files (removed, not purged) or not at all.
installed() {
  case "$(dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null)" in
    "" | not-installed | config-files) return 1 ;;
  esac
  return 0
}

missing=""
for p in $PACKAGES; do
  installed "$p" || missing="$missing $p"
done

if [ -n "$missing" ]; then
  echo "FAIL: TCP Wrappers is not installed; missing:$missing"
  exit 1
fi

echo "PASS: TCP Wrappers is installed ($PACKAGES)"
exit 0
