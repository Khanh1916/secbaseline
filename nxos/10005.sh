#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure
# unused/unnecessary services are properly disabled for security.
#
# VALIDATION CRITERIA:
# - TELNET feature must be disabled
# - DHCP feature must be disabled
# - NXAPI feature must be disabled
# - NXSDK feature must be disabled
# - NETCONF feature must be disabled
# - RESTCONF feature must be disabled
# - SCP-SERVER feature must be disabled
# - CDP must be globally disabled with "no cdp enable"
# - IP source routing must be disabled with "no ip source-route"
# - Returns PASS only if ALL criteria are met
#
# USAGE:
# ./10005.sh <config_file>
#
# EXAMPLES:
# ./10005.sh router-config.txt
# ./10005.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# no feature telnet
# no feature dhcp
# no feature nxapi
# no feature nxsdk
# no feature netconf
# no feature restconf
# no feature scp-server
# no cdp enable
# no ip source-route
#
# EXIT CODES:
# 0 - PASS: All unnecessary services are properly disabled
# 1 - FAIL: One or more services are enabled
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep utilities (standard on most Unix/Linux systems)

# Check arguments
if [ $# -ne 1 ]; then
    echo "FAIL"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "FAIL"
    exit 1
fi

# List of features that must be disabled
FEATURES_TO_CHECK=("telnet" "dhcp" "nxapi" "nxsdk" "netconf" "restconf" "scp-server")

# Function to check if a feature is enabled
check_feature_enabled() {
    local feature="$1"
    
    # Check if feature is explicitly enabled
    if grep -qi "^feature[[:space:]]\+${feature}[[:space:]]*$" "$CONFIG_FILE"; then
        echo "ENABLED"
        return
    fi
    
    # If feature is not mentioned or explicitly disabled, it's considered disabled
    echo "DISABLED"
}

# Function to check CDP status
check_cdp_status() {
    # Check if CDP is explicitly disabled - no space before "no cdp enable"
    if grep -qi "^no[[:space:]]\+cdp[[:space:]]\+enable[[:space:]]*$" "$CONFIG_FILE"; then
        echo "DISABLED"
        return
    fi
    
    # CDP not disabled - this fails the requirement
    echo "NOT_DISABLED"
}

# Function to check IP source-route status
check_ip_source_route_status() {
    # Check if IP source-route is explicitly disabled
    if grep -qi "^no[[:space:]]\+ip[[:space:]]\+source-route[[:space:]]*$" "$CONFIG_FILE"; then
        echo "DISABLED"
        return
    fi
    
    # IP source-route not disabled - this fails the requirement
    echo "NOT_DISABLED"
}

# Initialize validation status
failed=false
failure_reasons=()

# Check each feature
for feature in "${FEATURES_TO_CHECK[@]}"; do
    feature_status=$(check_feature_enabled "$feature")
    
    case "$feature_status" in
        "ENABLED")
            failed=true
            failure_reasons+=("Feature $feature is enabled (must be disabled)")
            ;;
        "DISABLED")
            # This is what we want - feature is disabled (either explicitly or by default)
            ;;
    esac
done

# Check CDP status
cdp_status=$(check_cdp_status)
case "$cdp_status" in
    "DISABLED")
        # This is what we want - CDP is properly disabled
        ;;
    "NOT_DISABLED")
        # CDP not disabled - fails the requirement
        failed=true
        failure_reasons+=("CDP not disabled (missing 'no cdp enable')")
        ;;
esac

# Check IP source-route status
ip_source_route_status=$(check_ip_source_route_status)
case "$ip_source_route_status" in
    "DISABLED")
        # This is what we want - IP source-route is properly disabled
        ;;
    "NOT_DISABLED")
        # IP source-route not disabled - fails the requirement
        failed=true
        failure_reasons+=("IP source-route not disabled (missing 'no ip source-route')")
        ;;
esac

# Output results
if [ "$failed" = true ]; then
    echo "FAIL"
    # Optionally output specific failure reasons (uncomment if needed)
    # for reason in "${failure_reasons[@]}"; do
    #     echo "  - $reason" >&2
    # done
    exit 1
else
    echo "PASS"
    exit 0
fi