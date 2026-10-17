#!/bin/bash

# DESCRIPTION:
# This script validates network device firewall filter configuration
# following security requirements for access control to management services
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Detect all open system services (SSH, HTTP, HTTPS, Telnet, NETCONF)
# 3. Verify firewall filters are applied on interfaces
# 4. Validate each open service port is protected by firewall filter with discard rules
# 5. Ensure allow rules exist for authorized source IPs
#
# STRICT VALIDATION REQUIREMENTS:
# - Limit access to declared IPs in access-list for remote device access via SSH
# - All open services must be protected by firewall filter with discard rules
# - Firewall filter must contain source-based allow rules with accept action
# - Firewall filter must be applied on interface
# - Must have discard rules for destination ports corresponding to open system services
#
# SAMPLE CONFIGURATION:
# set interfaces vme unit 0 family inet filter input limit-mgmt-access
# set firewall family inet filter limit-mgmt-access term allow-manager from source-prefix-list manager-ip
# set firewall family inet filter limit-mgmt-access term allow-manager then accept
# set firewall family inet filter limit-mgmt-access term block_non_manager from destination-port https
# set firewall family inet filter limit-mgmt-access term block_non_manager from destination-port telnet
# set firewall family inet filter limit-mgmt-access term block_non_manager from destination-port http
# set firewall family inet filter limit-mgmt-access term block_non_manager from destination-port 830
# set firewall family inet filter limit-mgmt-access term block_non_manager from destination-port ssh
# set firewall family inet filter limit-mgmt-access term block_non_manager then discard
# set firewall family inet filter limit-mgmt-access term accept_everything_else then accept
#
# USAGE:
# ./8004.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Firewall filter with source allow, accept and discard rules for corresponding open services, applied on interface
# 1 - FAILED: Missing or incorrect firewall filter configuration

# Check Junos config: services opened must be protected by firewall filter with discard rules
# Output only PASS or FAILED

if [ $# -ne 1 ]; then
    echo "Usage: $0 <junos_config_file>"
    exit 1
fi

CONFIG="$1"
[ ! -f "$CONFIG" ] && echo "FAILED" && exit 1

# === Default ports ===
declare -A default_ports=(
    ["ssh"]=22
    ["https"]=443
    ["telnet"]=23
    ["http"]=80
    ["netconf"]=830
)

# === Detect open services ===
declare -A service_ports
while IFS= read -r line; do
    for svc in "${!default_ports[@]}"; do
        case $svc in
            https) pattern="set system services web-management https" ;;
            http) pattern="set system services web-management http" ;;
            netconf) pattern="set system services netconf ssh" ;;
            *) pattern="set system services $svc" ;;
        esac
        if [[ "$line" =~ $pattern ]]; then
            port=$(echo "$line" | grep -oE "port[[:space:]]+[0-9]+" | awk '{print $2}')
            service_ports["$svc"]="${port:-${default_ports[$svc]}}"
        fi
    done
done < "$CONFIG"

# No services → PASS
if [ ${#service_ports[@]} -eq 0 ]; then
    echo "PASS"
    exit 0
fi

# === Applied filters ===
applied_filters=$(grep -E "set interfaces .* family inet filter input" "$CONFIG" \
                  | awk '{print $NF}' | sort -u)
[ -z "$applied_filters" ] && echo "FAILED" && exit 1

# === Function: check if port is covered ===
port_in_rule() {
    local port="$1"
    local rule="$2"
    case "$rule" in
        ssh)  [ "$port" -eq 22 ] && return 0 ;;
        https) [ "$port" -eq 443 ] && return 0 ;;
        telnet) [ "$port" -eq 23 ] && return 0 ;;
        http) [ "$port" -eq 80 ] && return 0 ;;
        830) [ "$port" -eq 830 ] && return 0 ;;
    esac
    if [[ "$rule" =~ ^[0-9]+$ ]] && [ "$rule" -eq "$port" ]; then return 0; fi
    if [[ "$rule" =~ ^[0-9]+-[0-9]+$ ]]; then
        local start=${rule%-*}
        local end=${rule#*-}
        (( port >= start && port <= end )) && return 0
    fi
    return 1
}

# === Check protection ===
for svc in "${!service_ports[@]}"; do
    port="${service_ports[$svc]}"
    port_protected=false
    for filter in $applied_filters; do
        mapfile -t rules < <(grep -E "set firewall .*filter $filter .*destination-port" "$CONFIG" | awk '{print $NF}')
        if grep -qE "set firewall .*filter $filter .*then discard" "$CONFIG"; then
            for rule in "${rules[@]}"; do
                if port_in_rule "$port" "$rule"; then
                    port_protected=true
                    break 2
                fi
            done
        fi
    done
    $port_protected || { echo "FAILED"; exit 0; }
done

# Check allow rule
if grep -qE "set firewall .*filter .* from source" "$CONFIG" \
   && grep -qE "set firewall .*filter .* then accept" "$CONFIG"; then
    echo "PASS"
else
    echo "FAILED"
fi