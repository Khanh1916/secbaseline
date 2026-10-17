#!/bin/bash
df_output=$(df -h /var/log 2>&1)

if echo "$df_output" | grep -q "No such file or directory"; then
	  echo "fail: /var/log không tồn tại hoặc không phải là filesystem riêng."
	    exit 1
fi

fstab_entry=$(grep -E '^[^#].*\s/var/log\s' /etc/fstab)

if [ -z "$fstab_entry" ]; then
	  echo "fail: /var/log không có entry trong /etc/fstab."
	    exit 1
fi

echo "pass: /var/log là một filesystem riêng và có entry trong /etc/fstab."
exit 0

