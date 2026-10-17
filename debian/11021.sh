#!/bin/bash
aslr_value=$(sysctl -n kernel.randomize_va_space 2>/dev/null)

if [ -z "$aslr_value" ]; then
	echo "fail: Không thể đọc giá trị kernel.randomize_va_space"
	exit 1
fi

if [ "$aslr_value" -eq 2 ]; then
	echo "pass: ASLR đã được bật đầy đủ (kernel.randomize_va_space = 2)."
	exit 0
else
	echo "fail: ASLR chưa được bật đầy đủ (kernel.randomize_va_space = $aslr_value)."
	exit 1
fi
