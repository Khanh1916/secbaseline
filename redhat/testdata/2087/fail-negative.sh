#!/bin/bash
# PASS_MAX_DAYS -1: passwords never expire.
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS\t-1/' /etc/login.defs
