#!/bin/bash
# PASS_MAX_DAYS 30.
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS\t30/' /etc/login.defs
