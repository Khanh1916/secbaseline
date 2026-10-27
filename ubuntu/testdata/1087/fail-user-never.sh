#!/bin/bash
# An account with a password never expires.
useradd -m alice
echo 'alice:Secret-Passw0rd-1' | chpasswd
chage -M 99999 alice
