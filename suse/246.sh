#!/bin/bash

if rpm -q telnet-server &>/dev/null; then
    echo "FAIL: telnet-server is installed"
    exit 1
else
    echo "PASS: package telnet-server is not installed"
    exit 0
fi
