#!/bin/bash

if dpkg -l | grep -E 'postfix|sendmail|exim4|msmtp|nullmailer' &> /dev/null; then
 echo "PASS: MTA is local-only mode"
 exit 0
fi

echo "FAIL: MTA is not configured for local-only mode"
exit 1
