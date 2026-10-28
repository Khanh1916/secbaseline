#!/bin/bash

# Every PAM password stack (common-password on Debian, Ubuntu and SUSE;
# system-auth and password-auth on the Red Hat family) must remember at least
# 5 previous passwords: remember=N on pam_pwhistory.so (without it, remember
# from /etc/security/pwhistory.conf, else the module default of 10) or on
# pam_unix.so.
MIN_REMEMBER=5
FILES="/etc/pam.d/common-password /etc/pam.d/system-auth /etc/pam.d/password-auth"
PWHISTORY_CONF=/etc/security/pwhistory.conf

conf_remember=$(awk -F= '/^[[:space:]]*remember[[:space:]]*=/ {v = $2; gsub(/[[:space:]]/, "", v)} END {print v}' "$PWHISTORY_CONF" 2>/dev/null)
[[ "$conf_remember" =~ ^[0-9]+$ ]] || conf_remember=10

found=0
bad=""
for f in $FILES; do
  [ -f "$f" ] || continue
  found=1
  best=0
  while IFS= read -r line; do
    n=$(echo "$line" | grep -oE '(^|[[:space:]])remember=[0-9]+' | tail -n 1 | cut -d= -f2)
    if [ -z "$n" ] && echo "$line" | grep -q 'pam_pwhistory\.so'; then
      n=$conf_remember
    fi
    [ -n "$n" ] && [ "$n" -gt "$best" ] && best=$n
  done < <(grep -E '^[[:space:]]*-?password[[:space:]].*pam_(pwhistory|unix)\.so' "$f")
  echo "INFO: $f remembers $best passwords"
  [ "$best" -ge "$MIN_REMEMBER" ] || bad="$bad $f(remember=$best)"
done

if [ $found -eq 0 ]; then
  echo "FAIL: No PAM password stack found ($FILES)"
  exit 1
fi

if [ -n "$bad" ]; then
  echo "FAIL: Password history must remember at least $MIN_REMEMBER passwords; found:$bad"
  exit 1
fi

echo "PASS: Every PAM password stack remembers at least $MIN_REMEMBER passwords"
exit 0
