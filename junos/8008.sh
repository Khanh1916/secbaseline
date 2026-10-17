#!/bin/bash

# DESCRIPTION:
# This script validates network device centralized authentication configuration
# following security requirements for remote access using RADIUS or TACACS+
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Detect RADIUS or TACACS+ server configurations
# 3. Validate authentication order includes RADIUS or TACACS+
# 4. Ensure all servers have proper secret/key configuration
#
# STRICT VALIDATION REQUIREMENTS:
# - Centralized authentication for remote access using RADIUS or TACACS+
# - At least one RADIUS or TACACS+ server must be configured
# - System authentication-order must include radius or tacplus
# - Every server must have corresponding secret/key configured
# - All authentication servers must be properly secured with secrets
#
# SAMPLE CONFIGURATION:
# set system radius-server 10.255.100.20 port 1812
# set system radius-server 10.255.100.20 secret R4d1u$k3y
# set system tacplus-server 10.255.100.40 port 49
# set system tacplus-server 10.255.100.40 secret T4c@cs+K3y
# set system radius-options password-protocol mschap-v2
# set system accounting events login
# set system accounting events change-log
# set system accounting events interactive-commands
# set system accounting destination radius server 10.255.100.20 accounting-port 1813
# set system accounting destination radius server 10.255.100.20 secret R4d1u$k3y
# set system accounting destination tacplus server 10.255.100.40 port 49
# set system accounting destination tacplus server 10.255.100.40 secret T4c@cs+K3y
# set system authentication-order radius
#
# USAGE:
# ./8008.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: At least one radius-server or tacplus-server configured, authentication-order set, all servers have secrets
# 1 - FAILED: Missing server configuration, authentication order, or server secrets

# Check RADIUS or TACACS+ authentication in Junos
# PASS if:
#  - At least 1 radius-server or tacplus-server configuration
#  - Has set system authentication-order radius or tacplus
#  - Every server has key/secret configured

if [ $# -ne 1 ]; then
    echo "Usage: $0 <junos_config_file>"
    exit 1
fi

CONFIG="$1"
[ ! -f "$CONFIG" ] && echo "FAILED" && exit 1

has_server=false
has_auth_order=false
missing_key=false

# === Check RADIUS ===
if grep -Eq "^set system radius-server " "$CONFIG"; then
    has_server=true
    grep -Eq "^set system authentication-order radius" "$CONFIG" && has_auth_order=true
    while read -r server; do
        # Check key for each server
        if ! grep -Eq "^set system radius-server $server secret" "$CONFIG"; then
            missing_key=true
        fi
    done < <(grep -E "^set system radius-server " "$CONFIG" | awk '{print $4}' | sort -u)
fi

# === Check TACACS+ ===
if grep -Eq "^set system tacplus-server " "$CONFIG"; then
    has_server=true
    grep -Eq "^set system authentication-order tacplus" "$CONFIG" && has_auth_order=true
    while read -r server; do
        # Check key for each server
        if ! grep -Eq "^set system tacplus-server $server secret" "$CONFIG"; then
            missing_key=true
        fi
    done < <(grep -E "^set system tacplus-server " "$CONFIG" | awk '{print $4}' | sort -u)
fi

# === Result ===
if $has_server && $has_auth_order && ! $missing_key; then
    echo "PASS"
else
    echo "FAILED"
fi