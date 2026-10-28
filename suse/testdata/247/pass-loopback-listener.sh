#!/bin/bash
# A process listens on port 25 on the loopback address only.
pkg_install ncat
nohup ncat -lk 127.0.0.1 25 >/dev/null 2>&1 &
sleep 1
