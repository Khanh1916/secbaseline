#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# disabling of unused protocols and services to minimize attack surface.
# Administrators should disable unnecessary services that are not required
# for normal network operations to reduce security vulnerabilities.
#
# VALIDATION CRITERIA:
# - TCP and UDP small services must be disabled (Echo, Discard, Daytime, Chargen)
# - Global CDP must be disabled
# - TFTP server must be disabled
# - DHCP server must be disabled
# - HTTP/HTTPS server must be disabled
# - TELNET server must be disabled
# - MPP block must not allow HTTP or TELNET services
#
# USAGE:
# ./9005.sh <config_file>
#
# EXAMPLES:
# ./9005.sh router-config.txt
# ./9005.sh /path/to/cisco-config.cfg
#
# FORBIDDEN CONFIGURATIONS:
# service ipv4 tcp-small-servers ...
# service ipv4 udp-small-servers ...
# service ipv6 tcp-small-servers ...
# service ipv6 udp-small-servers ...
# tftp vrf ... ipv4 server ...
# tftp vrf ... ipv6 server ...
# cdp
# dhcp ipv4
# dhcp ipv6
# telnet ipv4 server ...
# telnet ipv6 server ...
# allow HTTP ... (in MPP block)
# allow TELNET ... (in MPP block)
#
# SAMPLE SECURE CONFIGURATION:
# ! Disabled services (no configuration lines for these services)
# ! No service ipv4 tcp-small-servers
# ! No service ipv6 tcp-small-servers
# ! No tftp server configuration
# ! No dhcp server configuration
# ! No telnet server configuration
# ! No cdp global configuration
#
# EXIT CODES:
# 0 - PASS: Configuration meets security requirements (services disabled)
# 1 - FAILED: Configuration has enabled forbidden services
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, sed utilities (standard on most Unix/Linux systems)

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "File not found: $CONFIG_FILE"
    exit 1
fi

# Check for forbidden small services
check_small_services() {
    local failed_services=()
    
    # Check for TCP small services
    if grep -qi "^service[[:space:]]\+ipv4[[:space:]]\+tcp-small-servers" "$CONFIG_FILE"; then
        failed_services+=("IPv4 TCP small services enabled")
    fi
    
    if grep -qi "^service[[:space:]]\+ipv6[[:space:]]\+tcp-small-servers" "$CONFIG_FILE"; then
        failed_services+=("IPv6 TCP small services enabled")
    fi
    
    # Check for UDP small services
    if grep -qi "^service[[:space:]]\+ipv4[[:space:]]\+udp-small-servers" "$CONFIG_FILE"; then
        failed_services+=("IPv4 UDP small services enabled")
    fi
    
    if grep -qi "^service[[:space:]]\+ipv6[[:space:]]\+udp-small-servers" "$CONFIG_FILE"; then
        failed_services+=("IPv6 UDP small services enabled")
    fi
    
    # Return failed services array
    printf '%s\n' "${failed_services[@]}"
}

# Check for forbidden TFTP services
check_tftp_services() {
    local failed_services=()
    
    # Check for TFTP IPv4 server
    if grep -qi "^tftp[[:space:]]\+vrf.*ipv4[[:space:]]\+server" "$CONFIG_FILE"; then
        failed_services+=("TFTP IPv4 server enabled")
    fi
    
    # Check for TFTP IPv6 server
    if grep -qi "^tftp[[:space:]]\+vrf.*ipv6[[:space:]]\+server" "$CONFIG_FILE"; then
        failed_services+=("TFTP IPv6 server enabled")
    fi
    
    # Return failed services array
    printf '%s\n' "${failed_services[@]}"
}

# Check for forbidden CDP
check_cdp_service() {
    local failed_services=()
    
    # Check for global CDP
    if grep -qi "^cdp$" "$CONFIG_FILE"; then
        failed_services+=("Global CDP enabled")
    fi
    
    # Return failed services array
    printf '%s\n' "${failed_services[@]}"
}

# Check for forbidden DHCP services
check_dhcp_services() {
    local failed_services=()
    
    # Check for DHCP IPv4
    if grep -qi "^dhcp[[:space:]]\+ipv4" "$CONFIG_FILE"; then
        failed_services+=("DHCP IPv4 server enabled")
    fi
    
    # Check for DHCP IPv6
    if grep -qi "^dhcp[[:space:]]\+ipv6" "$CONFIG_FILE"; then
        failed_services+=("DHCP IPv6 server enabled")
    fi
    
    # Return failed services array
    printf '%s\n' "${failed_services[@]}"
}

# Check for forbidden TELNET services
check_telnet_services() {
    local failed_services=()
    
    # Check for TELNET IPv4 server
    if grep -qi "^telnet[[:space:]]\+ipv4[[:space:]]\+server" "$CONFIG_FILE"; then
        failed_services+=("TELNET IPv4 server enabled")
    fi
    
    # Check for TELNET IPv6 server
    if grep -qi "^telnet[[:space:]]\+ipv6[[:space:]]\+server" "$CONFIG_FILE"; then
        failed_services+=("TELNET IPv6 server enabled")
    fi
    
    # Return failed services array
    printf '%s\n' "${failed_services[@]}"
}

# Check for forbidden services in MPP block
check_mpp_services() {
    local failed_services=()
    
    # Extract control-plane management-plane block
    local mpp_content=$(sed -n '/^[[:space:]]*control-plane[[:space:]]*$/,/^![[:space:]]*$/p' "$CONFIG_FILE" | \
                       sed -n '/^[[:space:]]*management-plane[[:space:]]*$/,/^![[:space:]]*$/p')
    
    # If no MPP block exists, skip this check
    if [ -z "$mpp_content" ]; then
        return 0
    fi
    
    # Check for forbidden HTTP allow in MPP
    if echo "$mpp_content" | grep -qi "[[:space:]]\+allow[[:space:]]\+HTTP"; then
        failed_services+=("HTTP service allowed in MPP block")
    fi
    
    # Check for forbidden TELNET allow in MPP
    if echo "$mpp_content" | grep -qi "[[:space:]]\+allow[[:space:]]\+TELNET"; then
        failed_services+=("TELNET service allowed in MPP block")
    fi
    
    # Return failed services array
    printf '%s\n' "${failed_services[@]}"
}

# Main validation
# Collect all failed services
failed_issues=()

# Check all forbidden services and collect results
while IFS= read -r issue; do
    if [ -n "$issue" ]; then
        failed_issues+=("$issue")
    fi
done < <(check_small_services)

while IFS= read -r issue; do
    if [ -n "$issue" ]; then
        failed_issues+=("$issue")
    fi
done < <(check_tftp_services)

while IFS= read -r issue; do
    if [ -n "$issue" ]; then
        failed_issues+=("$issue")
    fi
done < <(check_cdp_service)

while IFS= read -r issue; do
    if [ -n "$issue" ]; then
        failed_issues+=("$issue")
    fi
done < <(check_dhcp_services)

while IFS= read -r issue; do
    if [ -n "$issue" ]; then
        failed_issues+=("$issue")
    fi
done < <(check_telnet_services)

while IFS= read -r issue; do
    if [ -n "$issue" ]; then
        failed_issues+=("$issue")
    fi
done < <(check_mpp_services)

# Generate final report
if [ ${#failed_issues[@]} -eq 0 ]; then
    echo "PASS"
    exit 0
else
    echo "FAILED"
    # Uncomment below lines for detailed debugging:
    # echo "FAILED: ${#failed_issues[@]} security issues found:"
    # for issue in "${failed_issues[@]}"; do
    #     echo "  - $issue"
    # done
    exit 1
fi