#!/bin/bash

FILES=(
  /etc/pam.d/system-auth
  /etc/pam.d/password-auth
  /etc/pam.d/common-auth
  /etc/pam.d/login
  /etc/pam.d/sshd
)

echo "=== Checking PAM 'deny' settings (pam_faillock / pam_tally2) ==="
found=0

for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue

  # pam_faillock.so
  if grep -q "pam_faillock.so" "$f"; then
    found=1
    echo "File: $f"
    grep "pam_faillock.so" "$f" | while read -r line; do
      deny=$(echo "$line" | grep -oE "deny=[0-9]+" | cut -d= -f2)
      if [ -n "$deny" ]; then
        echo "  pam_faillock.so deny=$deny"
      else
        echo "  pam_faillock.so deny not set in line: $line"
      fi
    done
    echo
  fi

  # pam_tally2.so
  if grep -q "pam_tally2.so" "$f"; then
    found=1
    echo "File: $f"
    grep "pam_tally2.so" "$f" | while read -r line; do
      deny=$(echo "$line" | grep -oE "deny=[0-9]+" | cut -d= -f2)
      if [ -n "$deny" ]; then
        echo "  pam_tally2.so deny=$deny"
      else
        echo "  pam_tally2.so deny not set in line: $line"
      fi
    done
    echo
  fi
done

if [ $found -eq 0 ]; then
  echo "No pam_faillock.so or pam_tally2.so configuration found."
  exit 1
fi