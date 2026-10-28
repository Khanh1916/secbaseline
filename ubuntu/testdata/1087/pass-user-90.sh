#!/bin/bash
# The only account with a password expires after 90 days.
useradd -m alice
echo 'alice:Secret-Passw0rd-1' | chpasswd
chage -M 90 alice
