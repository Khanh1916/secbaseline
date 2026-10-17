#!/bin/bash

# DESCRIPTION:
# This script validates network device security by checking for disabled unnecessary services
# following security requirements to minimize attack surface and reduce security risks
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Scan configuration for presence of security-risk services
# 3. Validate that all unnecessary services are disabled
# 4. Ensure only required services are enabled for security compliance
#
# STRICT VALIDATION REQUIREMENTS:
# - Disable unused protocols and services to limit attack risks
# - All listed security-risk services must be absent from configuration
# - Services should only be enabled when specifically required for operations
# - Minimize attack surface by disabling unnecessary network services
#
# SECURITY-RISK SERVICES TO DISABLE:
# - bbe-stats-service: Broadband Edge related; unnecessary if not running broadband services
# - database-replication: Only needed for database clusters; security risk if left open
# - dhcp-local-server: Disable if device is not serving as DHCP server
# - dtcp-only: Rarely used; only needed in special deployments
# - extension-service: Allows service extensions; exploitable if not tightly managed
# - finger: Reveals user information
# - ftp: Transmits data in plaintext; vulnerable to sniffing
# - netproxy: Used for proxy; rarely needed on core devices
# - outbound-ssh: Only needed for reverse SSH; security risk if exploited
# - resource-monitor: Resource statistics; not mandatory
# - rest: REST API; vulnerable to attacks if not well protected
# - service-deployment: Rarely used; should be disabled
# - subscriber-management: Only needed for subscriber services; disable if not used
# - telnet: Plaintext protocol; not secure
# - tftp-server: Plaintext protocol; easily abused for configuration downloads
# - web-management: Only enable HTTPS when needed; restrict IP access
# - xnm-clear-text: Plaintext management; very dangerous
# - xnm-ssl: SSL management; only enable when needed and restrict IP access
#
# SAMPLE CONFIGURATION:
# delete system services bbe-stats-service    
# delete system services database-replication 
# delete system services dhcp-local-server    
# delete system services dtcp-only            
# delete system services extension-service    
# delete system services finger               
# delete system services ftp                            
# delete system services netproxy             
# delete system services outbound-ssh         
# delete system services resource-monitor     
# delete system services rest                 
# delete system services service-deployment                 
# delete system services subscriber-management
# delete system services telnet               
# delete system services tftp-server          
# delete system services web-management       
# delete system services xnm-clear-text       
# delete system services xnm-ssl
#
# USAGE:
# ./8005.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: No security-risk services are enabled
# 1 - FAILED: One or more security-risk services are enabled

# Check Junos services that should be disabled to reduce security risks
# Returns PASS if all are disabled

if [ $# -ne 1 ]; then
    echo "Usage: $0 <junos_config_file>"
    exit 1
fi

CONFIG="$1"
[ ! -f "$CONFIG" ] && echo "FAILED" && exit 1

# List of services that should be disabled
services_to_disable=(
    "bbe-stats-service"
    "database-replication"
    "dhcp-local-server"
    "dtcp-only"
    "extension-service"
    "finger"
    "ftp"
    "netproxy"
    "outbound-ssh"
    "resource-monitor"
    "rest"
    "service-deployment"
    "subscriber-management"
    "telnet"
    "tftp-server"
    "web-management"
    "xnm-clear-text"
    "xnm-ssl"
)

found=false

for svc in "${services_to_disable[@]}"; do
    if grep -qE "set system services[[:space:]]+$svc(\s|$)" "$CONFIG"; then
        found=true
        break
    fi
done

if $found; then
    echo "FAILED"
else
    echo "PASS"
fi