#!/bin/bash
# A process listens on port 25 on every address.
pkg_install netcat-openbsd
nohup nc -lk 0.0.0.0 25 >/dev/null 2>&1 &
sleep 1
