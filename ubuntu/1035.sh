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
	echo "PASS: Packages xserver-common and xorg are not installed"
	exit 0
else
	echo "FAIL: Package xserver-common or xorg is installed"
	exit 1
fi
