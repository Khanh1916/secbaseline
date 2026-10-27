#!/bin/bash
# Every banner holds a plain warning.
echo 'Authorized users only. All activity may be monitored and reported.' | tee /etc/issue /etc/issue.net /etc/motd >/dev/null
