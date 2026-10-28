#!/bin/bash
# One log file is readable by everyone.
find /var/log -type f -exec chmod g-wx,o-rwx {} +
touch /var/log/syslog
chmod 644 /var/log/syslog
