#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# authentication configuration on all line interfaces (console, default, template).
# While IOS XR requires authentication by default, this script enforces additional
# security with secret or login authentication configuration.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - All line blocks must have either "secret" or "login authentication" configuration
# - Applies to: line console, line default, line template
#
# USAGE:
# ./9007.sh <config_file>
#
# EXAMPLES:
# ./9007.sh router-config.txt
# ./9007.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: All line configurations have proper authentication
# 1 - FAIL: Some line configurations missing authentication
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, sed utilities (standard on most Unix/Linux systems)
#
# EXAMPLE VALID CONFIGURATION:
# line console
#  secret 5 $1$zxaa$NtJsWebFvL2Wp88r4mJEr.
#  login authentication default
# !
# line default
#  secret 5 $1$zxaa$NtJsWebFvL2Wp88r4mJEr.
#  login authentication default
# !
# line template VTY-TEMP
#  secret 5 $1$zxaa$NtJsWebFvL2Wp88r4mJEr.
#  login authentication default
# !

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists and is readable
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: File not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -r "$CONFIG_FILE" ]; then
    echo "ERROR: Cannot read file: $CONFIG_FILE"
    exit 1
fi

# Function to check line authentication configuration
check_line_authentication() {
    # Find all line configurations (console, default, template)
    local line_configs=$(grep "^line[[:space:]]\+\(console\|default\|template\)" "$CONFIG_FILE")
    
    if [ -z "$line_configs" ]; then
        return 1  # No line configurations found
    fi
    
    # Check each line configuration
    while IFS= read -r line_config; do
        # Extract line type and name
        local line_type=$(echo "$line_config" | awk '{print $2}')
        local line_name=""
        if [ "$line_type" = "template" ]; then
            line_name=$(echo "$line_config" | awk '{print $3}')
        fi
        
        # Extract the block for this line configuration
        local line_block=""
        if [ "$line_type" = "template" ]; then
            line_block=$(sed -n "/^line[[:space:]]\+template[[:space:]]\+$line_name[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE")
        else
            line_block=$(sed -n "/^line[[:space:]]\+$line_type[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE")
        fi
        
        # Check if this block has either secret or login authentication
        local has_secret=false
        local has_login_auth=false
        
        if echo "$line_block" | grep -q "^[[:space:]]\+secret[[:space:]]\+"; then
            has_secret=true
        fi
        
        if echo "$line_block" | grep -q "^[[:space:]]\+login[[:space:]]\+authentication[[:space:]]\+"; then
            has_login_auth=true
        fi
        
        # Line must have at least one authentication method
        if [ "$has_secret" = false ] && [ "$has_login_auth" = false ]; then
            return 1  # Line missing authentication configuration
        fi
        
    done <<< "$line_configs"
    
    return 0  # All line configurations have authentication
}

# Main validation logic
check_line_authentication
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Some line configurations missing secret or login authentication"
    exit 1
fi

# Check passed
echo "PASS"
exit 0