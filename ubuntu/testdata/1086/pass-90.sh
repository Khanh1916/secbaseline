#!/bin/bash
# PASS_MAX_DAYS 90.
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS\t90/' /etc/login.defs
