#!/bin/bash

FILES=(
  /etc/pam.d/system-auth
  /etc/pam.d/password-auth
  /etc/pam.d/common-auth
  /etc/pam.d/login
  /etc/pam.d/sshd
)

found=0

for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  if grep -q "pam_faillock.so" "$f"; then
    found=1
    echo "File: $f"
    grep "pam_faillock.so" "$f" | while read -r line; do
      deny=$(echo "$line" | grep -oE "deny=[0-9]+" | cut -d= -f2)
      if [ -n "$deny" ]; then
        echo "  → deny=$deny"
      else
        echo "  → deny not set in line: $line"
      fi
    done
    echo
  fi
done

if [ $found -eq 0 ]; then
  echo "No pam_faillock.so configuration found."
  exit 1
fi
