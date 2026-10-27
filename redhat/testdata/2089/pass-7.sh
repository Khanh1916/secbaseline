#!/bin/bash
# PASS_MIN_DAYS 7.
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS\t7/' /etc/login.defs
