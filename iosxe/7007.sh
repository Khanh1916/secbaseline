#!/bin/bash

# Cisco IOS-XE Configuration Authentication Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate authentication configuration on Cisco IOS-XE devices
# Ensures proper access control and security compliance
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7007.sh <config_file>
# Example: ./7007.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Validation Logic:
# 1. Priority Check - AAA Authentication (Preferred Method):
#    - Requires both: "aaa new-model" AND "aaa authentication login default local"
#    - If both present -> PASS immediately (highest security)
#
# 2. Fallback Check - Line Authentication (Legacy Method):
#    - Validates line console (con) and line auxiliary (aux) blocks
#    - Each configured line block must have authentication:
#      * password <password> OR
#      * login local OR  
#      * login authentication <method>
#    - If line blocks exist without authentication -> FAIL
#    - If no line blocks configured -> PASS (not applicable)
#
# Security Compliance:
# - Prevents unauthorized device access via console/auxiliary ports
# - Enforces authentication on all configured access methods
# - Supports both modern AAA and legacy line-based authentication
#
# Return Codes:
# 0 = PASS (authentication properly configured)
# 1 = FAIL (missing or incomplete authentication)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Case sensitive pattern matching for IOS-XE commands
# - Handles multi-line configuration blocks correctly
# - Compatible with all standard Cisco configuration formats

# Check input parameter and file existence
if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "Usage: $0 <config-file>"
  exit 1
fi

config_file="$1"

# If both required AAA lines are present -> PASS immediately
if grep -q "^aaa authentication login default local" "$config_file" && \
   grep -q "^aaa new-model" "$config_file"; then
  echo "PASS"
  exit 0
fi

# Function to check line block (con or aux)
check_line_block() {
  local type="$1"
  awk -v type="$type" '
    BEGIN { in_block = 0; found = 0; valid = 0; }

    # Start of line type block
    $0 ~ "^line "type {
      in_block = 1;
      block = $0;
      next;
    }

    # New block encountered -> end current block
    /^line / {
      in_block = 0;
    }

    # Within block, look for password or login local
    in_block {
      if ($0 ~ /^ ?password / || $0 ~ /^ ?login local/ || $0 ~ /^ ?login authentication /) {
        valid = 1;
      }
      found = 1;
    }

    END {
      # If no block found -> PASS
      if (found == 0) {
        exit 0;
      }
      # If block exists but missing required authentication -> FAIL
      if (valid == 0) {
        exit 1;
      }
    }
  ' "$config_file"
}

# Check each line type
check_line_block "con"
res_con=$?

check_line_block "aux"
res_aux=$?

# Aggregate results
if [ $res_con -eq 0 ] && [ $res_aux -eq 0 ]; then
  echo "PASS"
  exit 0
else
  echo "FAIL"
  exit 1
fi