#!/bin/bash
df_output=$(df -h /var 2>&1)
if echo "$df_output" | grep -q "No such file or directory"; then
	echo "fail: /var không tồn tại hoặc không phải là filesystem riêng."
	exit 1
fi
fstab_entry=$(grep -E '^[^#].*\s/var\s' /etc/fstab)

if [ -z "$fstab_entry" ]; then
	echo "fail: /var không có entry trong /etc/fstab."
	exit 1
fi
echo "pass: /var là một filesystem riêng và có entry trong /etc/fstab."
exit 0
