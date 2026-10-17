#!/bin/bash
xserver_output=$(dpkg -s xserver-common 2>&1)
xorg_output=$(dpkg -s xorg 2>&1)

is_not_installed() {
	echo "$1" | grep -q "is not installed and no information is available"
}

is_installed() {
	echo "$1" | grep -q "Status: install ok installed"
}

if is_not_installed "$xserver_output" && is_not_installed "$xorg_output"; then
	echo "pass: Các gói xserver-common và xorg không được cài đặt."
	exit 0
else
	echo "fail: Một trong hai gói xserver-common hoặc xorg đang được cài đặt."
	exit 1
fi
