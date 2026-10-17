#!/bin/bash
df_output=$(df -h /var 2>&1)
if echo "$df_output" | grep -q "No such file or directory"; then
	echo "FAIL: /var does not exist or is not a separate filesystem"
	exit 1
fi
fstab_entry=$(grep -E '^[^#].*\s/var\s' /etc/fstab)

if [ -z "$fstab_entry" ]; then
	echo "FAIL: /var has no entry in /etc/fstab"
	exit 1
fi
echo "PASS: /var is a separate filesystem with an entry in /etc/fstab"
exit 0
