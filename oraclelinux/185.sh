#!/bin/bash

# New passwords must be hashed with SHA-512 or the stronger yescrypt, both in
# /etc/login.defs (ENCRYPT_METHOD, used by useradd and chpasswd, and by
# pam_unix when its line names no method) and on every active pam_unix.so
# password line that names a method.
LOGIN_DEFS=/etc/login.defs
FILES="/etc/pam.d/common-password /etc/pam.d/system-auth /etc/pam.d/password-auth"

method=$(awk '$1 == "ENCRYPT_METHOD" {v = $2} END {print toupper(v)}' "$LOGIN_DEFS" 2>/dev/null)
echo "INFO: $LOGIN_DEFS: ENCRYPT_METHOD ${method:-unset}"
bad=""
case "$method" in
  SHA512 | YESCRYPT) ;;
  *) bad=" $LOGIN_DEFS:ENCRYPT_METHOD=${method:-unset}" ;;
esac

for f in $FILES; do
  [ -f "$f" ] || continue
  for m in $(grep -E '^[[:space:]]*-?password[[:space:]].*pam_unix\.so' "$f" |
    awk '{for (i = 1; i <= NF; i++) if ($i ~ /^(md5|bigcrypt|sha256|sha512|blowfish|gost_yescrypt|yescrypt)$/) print $i}'); do
    echo "INFO: $f: pam_unix.so $m"
    case "$m" in
      sha512 | yescrypt) ;;
      *) bad="$bad $f:$m" ;;
    esac
  done
done

if [ -n "$bad" ]; then
  echo "FAIL: Passwords must be hashed with SHA-512 or yescrypt; found:$bad"
  exit 1
fi

echo "PASS: Passwords are hashed with SHA-512 or yescrypt"
exit 0
