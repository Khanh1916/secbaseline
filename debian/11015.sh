#!/bin/bash
df_output=$(df -h /var/log/audit 2>&1)

if echo "$df_output" | grep -q "No such file or directory"; then
	  echo "fail: /var/log/audit không tồn tại hoặc không phải là filesystem riêng."
	    exit 1
fi

fstab_entry=$(grep -E '^[^#].*\s/var/log/audit\s' /etc/fstab)

if [ -z "$fstab_entry" ]; then
	  echo "fail: /var/log/audit không có entry trong /etc/fstab."
	    exit 1
fi

echo "pass: /var/log/audit là một filesystem riêng và có entry trong /etc/fstab."
exit 0
