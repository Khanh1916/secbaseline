#!/bin/bash
# PASS_MIN_DAYS 1.
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS\t1/' /etc/login.defs
