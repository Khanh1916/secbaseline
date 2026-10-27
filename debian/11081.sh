#!/bin/bash

# Every PAM auth stack of the distribution (common-auth on Debian, Ubuntu and
# SUSE; system-auth and password-auth on the Red Hat family) must use
# pam_faillock.so or pam_tally2.so on an active auth line.
FILES="/etc/pam.d/common-auth /etc/pam.d/system-auth /etc/pam.d/password-auth"

found=0
missing=""
for f in $FILES; do
  [ -f "$f" ] || continue
  found=1
  module=$(grep -E '^[[:space:]]*-?auth[[:space:]].*pam_(faillock|tally2)\.so' "$f" | grep -oE 'pam_(faillock|tally2)\.so' | head -n 1)
  if [ -n "$module" ]; then
    echo "INFO: $f uses $module"
  else
    missing="$missing $f"
  fi
done

if [ $found -eq 0 ]; then
  echo "FAIL: No PAM auth stack found ($FILES)"
  exit 1
fi

if [ -n "$missing" ]; then
  echo "FAIL: No account lockout module (pam_faillock.so or pam_tally2.so) in:$missing"
  exit 1
fi

echo "PASS: An account lockout module is configured in every PAM auth stack"
exit 0
