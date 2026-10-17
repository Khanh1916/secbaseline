#!/bin/bash

if grep "remember=" /etc/pam.d/common-password 2>/dev/null | grep -E "pam_unix\.so.*remember=[0-9]+" &>/dev/null; then
  echo "/etc/pam.d/common-password has remember=N configured for pam_unix.so."
  exit 0
fi

echo "/etc/pam.d/common-password does not have remember=N configured for pam_unix.so."
exit 1
