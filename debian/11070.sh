#!/bin/bash

if [ "$(stat -c '%a %U %G' /etc/ssh/sshd_config 2>/dev/null)" != "600 root root" ]; then
 echo "/etc/ssh/sshd_config permissions are not set to '600 root root'."
 exit 1
fi

echo "/etc/ssh/sshd_config permissions are configured."
exit 0
