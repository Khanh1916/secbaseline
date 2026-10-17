#!/bin/bash

PAM_FILES=(
  /etc/pam.d/common-password
  /etc/pam.d/system-auth
  /etc/pam.d/password-auth
)
PWQUALITY_CONF="/etc/security/pwquality.conf"

found_pam=0
for f in "${PAM_FILES[@]}"; do
  if [ -f "$f" ] && grep -q "pam_pwquality.so" "$f"; then
    echo "Found pam_pwquality.so in $f"
    found_pam=1
  fi
done

if [ $found_pam -eq 0 ]; then
  echo "pam_pwquality.so not found in any PAM configuration files."
  exit 1
fi

if [ -f "$PWQUALITY_CONF" ]; then
  echo
  grep -E "^\s*(minlen|minclass|ucredit|lcredit|dcredit|ocredit)\s*=" "$PWQUALITY_CONF" | sed 's/^[[:space:]]*//'
else
  echo
  grep "pam_pwquality.so" "${PAM_FILES[@]}" 2>/dev/null | grep -oE "(minlen|minclass|ucredit|lcredit|dcredit|ocredit)=[^[:space:]]+" | tr ' ' '\n' | sort | uniq
fi
