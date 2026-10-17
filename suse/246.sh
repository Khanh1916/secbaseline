#!/bin/bash

if rpm -q telnet-server &>/dev/null; then
    echo "telnet-server is installed"
    exit 1
else
    echo "package telnet-server is not installed"
    exit 0
fi
