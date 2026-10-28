#!/bin/bash

PACKAGES="setroubleshoot"

# A package counts as installed unless dpkg knows it only by its leftover
# configuration files (removed, not purged) or not at all.
installed() {
  case "$(dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null)" in
    "" | not-installed | config-files) return 1 ;;
  esac
  return 0
}

found=""
for p in $PACKAGES; do
  installed "$p" && found="$found $p"
done

if [ -n "$found" ]; then
  echo "FAIL: SETroubleshoot is installed:$found"
  exit 1
fi

echo "PASS: SETroubleshoot is not installed (checked: $PACKAGES)"
exit 0
