#!/bin/bash
df_output=$(df -h /home 2>&1)

if echo "$df_output" | grep -q "No such file or directory"; then
	  echo "FAIL: /home does not exist or is not a separate filesystem"
	    exit 1
fi

fstab_entry=$(grep -E '^[^#].*\s/home\s' /etc/fstab)

if [ -z "$fstab_entry" ]; then
	  echo "FAIL: /home has no entry in /etc/fstab"
	    exit 1
fi

echo "PASS: /home is a separate filesystem with an entry in /etc/fstab"
exit 0
