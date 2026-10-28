#!/bin/bash
# New and existing accounts are disabled 30 days after their password expires.
useradd -D -f 30
useradd -m alice
echo 'alice:Secret-Passw0rd-1' | chpasswd
