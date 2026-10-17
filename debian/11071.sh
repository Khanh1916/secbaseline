#!/bin/bash

if [ -f /etc/ssh/sshd_config ] && ( grep -E "^Protocol\s+2" /etc/ssh/sshd_config 2>/dev/null | grep -qw "Protocol 2" || ! grep -E "^Protocol" /etc/ssh/sshd_config 2>/dev/null ); then
  echo "/etc/ssh/sshd_config uses Protocol 2 or defaults to SSH-2."
  exit 0
fi
  
echo "/etc/ssh/sshd_config does not exist or does not use Protocol 2."
exit 1
