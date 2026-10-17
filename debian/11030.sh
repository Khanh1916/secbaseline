#!/bin/bash
files=("/etc/issue" "/etc/issue.net")
banner_file=$(grep "^Banner" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')

if [ -n "$banner_file" ] && [ -f "$banner_file" ]; then
	files+=("$banner_file")
fi

os_keywords=("Ubuntu" "Debian" "CentOS" "Red Hat" "Fedora" "SUSE" "kernel" "release" "version")

for file in "${files[@]}"; do
	
	if [ ! -f "$file" ]; then
		continue
	fi
	if grep -iq -e "${os_keywords[0]}" -e "${os_keywords[1]}" -e "${os_keywords[2]}" -e "${os_keywords[3]}" -e "${os_keywords[4]}" -e "${os_keywords[5]}" -e "${os_keywords[6]}" -e "${os_keywords[7]}" -e "${os_keywords[8]}" "$file"; then
		echo "FAIL: File $file contains detailed OS information"
		exit 1
	fi
done

echo "PASS: Banner files do not contain detailed OS version information"
exit 0

