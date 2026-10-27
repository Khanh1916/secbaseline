#!/bin/bash
# /etc/issue as issue-generator writes it at boot.
. /etc/os-release
echo "Welcome to $PRETTY_NAME - Kernel \r (\l)." >/etc/issue
