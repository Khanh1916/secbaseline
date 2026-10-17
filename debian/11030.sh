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
		echo "fail: File $file chứa thông tin hệ điều hành chi tiết."
		exit 1
	fi
done

echo "pass: Các file banner không chứa thông tin phiên bản hệ điều hành chi tiết."
exit 0

