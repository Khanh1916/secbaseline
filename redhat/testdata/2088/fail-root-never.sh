#!/bin/bash
# root has a password that never expires.
echo 'root:Secret-Passw0rd-1' | chpasswd
chage -M 99999 root
