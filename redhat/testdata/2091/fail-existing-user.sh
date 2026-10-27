#!/bin/bash
# The default is 30, but an older account with a password has no INACTIVE.
useradd -m alice
echo 'alice:Secret-Passw0rd-1' | chpasswd
useradd -D -f 30
