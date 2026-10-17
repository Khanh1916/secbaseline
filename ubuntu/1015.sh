#!/bin/bash
df_output=$(df -h /var/log/audit 2>&1)

if echo "$df_output" | grep -q "No such file or directory"; then
	  echo "FAIL: /var/log/audit does not exist or is not a separate filesystem"
	    exit 1
fi

fstab_entry=$(grep -E '^[^#].*\s/var/log/audit\s' /etc/fstab)

if [ -z "$fstab_entry" ]; then
	  echo "FAIL: /var/log/audit has no entry in /etc/fstab"
	    exit 1
fi

echo "PASS: /var/log/audit is a separate filesystem with an entry in /etc/fstab"
exit 0
