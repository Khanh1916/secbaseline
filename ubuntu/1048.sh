#!/bin/bash

if dpkg -l | grep -E 'postfix|sendmail|exim4|msmtp|nullmailer' &> /dev/null; then
 echo "MTA is local-only mode"
 exit 0
fi

echo "MTA: Failed to swicth local-only mode"
exit 1
