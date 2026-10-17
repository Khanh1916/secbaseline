#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# exec-timeout configuration is present and meets security standards.
#
# VALIDATION CRITERIA:
# - All line console sections must have "exec-timeout 5"
# - All line vty sections must have "exec-timeout 5"
# - Timeout value must be exactly 5 minutes for security compliance
# - Returns PASS only if ALL line sections have correct exec-timeout
#
# USAGE:
# ./10003.sh <config_file>
#
# EXAMPLES:
# ./10003.sh router-config.txt
# ./10003.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# line console
#   exec-timeout 5
# line vty
#   exec-timeout 5
#
# EXIT CODES:
# 0 - PASS: All line sections have exec-timeout 5
# 1 - FAILED: Missing or incorrect exec-timeout configuration
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, awk, sed utilities (standard on most Unix/Linux systems)

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

# Function to check exec-timeout in a specific line section
check_exec_timeout_in_section() {
    local line_type="$1"
    
    # Extract the specific line section and check for exec-timeout 5
    awk -v line_type="$line_type" '
    BEGIN { in_section = 0; found_section = 0; found_valid = 0 }
    
    # Match line console or line vty - "line" always starts at beginning of line
    tolower($0) ~ "^line[[:space:]]+" line_type "[[:space:]]*" {
        in_section = 1
        found_section = 1
        next
    }
    
    # End section when we hit another command that starts at beginning of line OR empty line
    in_section && (/^[^[:space:]]/ || /^[[:space:]]*$/) {
        in_section = 0
    }
    
    # Check for exact "exec-timeout 5" in current section
    in_section && /^[[:space:]]+exec-timeout[[:space:]]+5[[:space:]]*$/ {
        print "VALID_TIMEOUT_FOUND"
        found_valid = 1
        exit 0
    }
    
    END {
        if (found_valid == 1) {
            # Already printed VALID_TIMEOUT_FOUND, do nothing
        } else if (found_section == 0) {
            print "SECTION_NOT_FOUND"
        } else {
            print "TIMEOUT_NOT_FOUND"
        }
    }
    ' "$CONFIG_FILE"
}

# Check for line console sections
console_result=$(check_exec_timeout_in_section "console")
console_sections=$(grep -c "^line[[:space:]]\+console" "$CONFIG_FILE")

# Check for line vty sections  
vty_result=$(check_exec_timeout_in_section "vty")
vty_sections=$(grep -c "^line[[:space:]]\+vty" "$CONFIG_FILE")

# Validation logic
failed=false
failure_reasons=()

# Check console configuration
if [ "$console_sections" -gt 0 ]; then
    if [ "$console_result" != "VALID_TIMEOUT_FOUND" ]; then
        failed=true
        failure_reasons+=("Console line missing or incorrect exec-timeout 5")
    fi
fi

# Check vty configuration
if [ "$vty_sections" -gt 0 ]; then
    if [ "$vty_result" != "VALID_TIMEOUT_FOUND" ]; then
        failed=true
        failure_reasons+=("VTY line missing or incorrect exec-timeout 5")
    fi
fi

# Check if we have any line sections at all
if [ "$console_sections" -eq 0 ] && [ "$vty_sections" -eq 0 ]; then
    failed=true
    failure_reasons+=("No line console or line vty sections found in configuration")
fi

# Debug output (uncomment for troubleshooting)
# echo "Console sections: $console_sections, result: $console_result" >&2
# echo "VTY sections: $vty_sections, result: $vty_result" >&2
# echo "Failed: $failed" >&2

# Output results
if [ "$failed" = true ]; then
    echo "FAILED"
    # Optionally output specific failure reasons (uncomment if needed)
    # for reason in "${failure_reasons[@]}"; do
    #     echo "  - $reason" >&2
    # done
    exit 1
else
    echo "PASS"
    exit 0
fi