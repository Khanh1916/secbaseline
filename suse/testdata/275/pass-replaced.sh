#!/bin/bash
# The shipped PermitRootLogin yes in sshd_config replaced with no.
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
