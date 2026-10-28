#!/bin/bash
# pam_faillock with its default of 3.
for f in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  sed -i -e '/^auth.*pam_unix.so/i auth        required      pam_faillock.so preauth silent' \
    -e '/^auth.*pam_unix.so/a auth        required      pam_faillock.so authfail' \
    -e '/^account.*pam_unix.so/i account     required      pam_faillock.so' "$f"
done
