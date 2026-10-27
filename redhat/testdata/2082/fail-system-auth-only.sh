#!/bin/bash
# pam_faillock is in system-auth only, not in password-auth (used by sshd).
sed -i -e '/^auth.*pam_unix.so/i auth        required      pam_faillock.so preauth silent' /etc/pam.d/system-auth
