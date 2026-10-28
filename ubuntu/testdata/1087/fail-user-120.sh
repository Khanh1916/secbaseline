#!/bin/bash
# An account with a password expires only after 120 days.
useradd -m alice
echo 'alice:Secret-Passw0rd-1' | chpasswd
chage -M 120 alice
