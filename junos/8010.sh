#!/bin/bash

# DESCRIPTION:
# This script validates network device SNMP security configuration
# following security requirements for safe SNMP configuration and IP access restrictions
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Detect SNMP version (v2 or v3) in use
# 3. Apply version-specific security validation rules
# 4. Ensure proper IP restrictions and community string security
#
# STRICT VALIDATION REQUIREMENTS:
# - Secure SNMP configuration with IP access restrictions
# - Limit SNMP server access to authorized IPs only
# - Ensure only allowed IPs with corresponding community strings and RO (read-only) permissions can connect to device via SNMP
# - No unsafe community strings or write access permissions
#
# SNMP VERSION 2 REQUIREMENTS:
# 1. No common unsafe community strings (public, private, admin, monitor, security)
# 2. Read-only access only (no read-write/write-view)
# 3. All communities must have client-list or clients with restrict
# 4. All client-lists must have default restrict or 0.0.0.0/0 restrict
#
# SNMP VERSION 3 REQUIREMENTS:
# 1. Must have interface restrictions (set snmp interface)
# 2. No write access (read-write/write-view)
# 3. Must have policy filter with destination-port snmp/161 and discard
#
# SAMPLE CONFIGURATION:
# set snmp location DC1-Rack:18-Row:22
# set snmp contact "CompanyName NOC:18008888"
# set snmp interface vme.0
# set snmp view secure-view oid system include
# set snmp view secure-view oid interfaces include
# set snmp community "Nsri41suhh" view inventory-only
# set snmp community "Nsri41suhh" authorization read-only
# set snmp community "Nsri41suhh" clients 10.255.100.20/32
# set snmp community "Nsri41suhh" clients 0.0.0.0/0 restrict
# set snmp client-list monitor 10.255.100.10/32
# set snmp client-list monitor 0.0.0.0/0 restrict
# set snmp community "d6Xm2XUAFC" client-list-name monitor
# set snmp v3 usm local-engine user secure-snmp authentication-sha authentication-password "M4nhMatKhau2025!"
# set snmp v3 usm local-engine user secure-snmp privacy-aes128 privacy-password "B4oMatKhau2026!"
# set firewall family inet filter limit-mgmt-access term block_non_manager from destination-port snmp
# set firewall family inet filter limit-mgmt-access term block_non_manager then discard
# set interfaces vme unit 0 family inet filter input limit-mgmt-access
#
# USAGE:
# ./8010.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: SNMP configuration meets security requirements
# 1 - FAILED: SNMP configuration does not meet security requirements

# SNMP Configuration Security Checker
# Check SNMP configuration according to security standards

CONFIG_FILE="$1"

# Check if config file is provided
if [[ -z "$CONFIG_FILE" || ! -f "$CONFIG_FILE" ]]; then
    echo "FAILED"
    exit 1
fi

# Detect SNMP version
if grep -q "set snmp v3" "$CONFIG_FILE"; then
    SNMP_VERSION="v3"
else
    SNMP_VERSION="v2"
fi

# Function to check SNMPv2 requirements
check_snmpv2() {
    # 1. Check for insecure community strings
    if grep -E "set snmp community.*(public|private|admin|monitor|security)" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 2. Check for read-write access
    if grep -E "set snmp.*read-write|write-view" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 3. Check client-list/clients for all communities
    local communities=$(grep "set snmp community" "$CONFIG_FILE" | sed -E 's/.*set snmp community ['\''"]?([^'\''\" ]+)['\''"]?.*/\1/' | sort -u)
    
    for community in $communities; do
        # Check if community has client-list or clients
        if ! grep -E "set snmp community.*$community.*(client-list|clients)" "$CONFIG_FILE" >/dev/null 2>&1; then
            return 1
        fi
        
        # If using clients, check for restrict
        if grep -E "set snmp community.*$community.*clients" "$CONFIG_FILE" >/dev/null 2>&1; then
            if ! grep -E "set snmp community.*$community.*clients.*0\.0\.0\.0/0.*restrict" "$CONFIG_FILE" >/dev/null 2>&1; then
                return 1
            fi
        fi
        
        # If using client-list, check for default restrict
        if grep -E "set snmp community.*$community.*client-list" "$CONFIG_FILE" >/dev/null 2>&1; then
            local client_list=$(grep -E "set snmp community.*$community.*client-list" "$CONFIG_FILE" | sed -E 's/.*client-list[^a-zA-Z0-9_-]*([a-zA-Z0-9_-]+).*/\1/')
            if ! grep -E "set snmp client-list $client_list.*(default restrict|0\.0\.0\.0/0.*restrict)" "$CONFIG_FILE" >/dev/null 2>&1; then
                return 1
            fi
        fi
    done
    
    # 4. Check all client-lists have default restrict
    local all_client_lists=$(grep "set snmp client-list" "$CONFIG_FILE" | sed -E 's/.*set snmp client-list ([^ ]+).*/\1/' | sort -u)
    for client_list in $all_client_lists; do
        if ! grep -E "set snmp client-list $client_list.*(default restrict|0\.0\.0\.0/0.*restrict)" "$CONFIG_FILE" >/dev/null 2>&1; then
            return 1
        fi
    done
    
    return 0
}

# Function to check SNMPv3 requirements
check_snmpv3() {
    # 1. Check for interface restrictions
    if ! grep -E "set snmp interface" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 2. Check for read-write access
    if grep -E "set snmp.*read-write|write-view" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 3. Check for policy filter with SNMP restrictions
    if ! grep -E "from destination-port (snmp|161)" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    if ! grep -E "then discard" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Main check logic
if [[ "$SNMP_VERSION" == "v3" ]]; then
    # Check if both v2 and v3 exist (mixed environment)
    if grep -q "set snmp community" "$CONFIG_FILE"; then
        # Mixed environment - check both
        if check_snmpv2 && check_snmpv3; then
            echo "PASS"
        else
            echo "FAILED"
        fi
    else
        # v3 only
        if check_snmpv3; then
            echo "PASS"
        else
            echo "FAILED"
        fi
    fi
else
    # v2 only
    if check_snmpv2; then
        echo "PASS"
    else
        echo "FAILED"
    fi
fi