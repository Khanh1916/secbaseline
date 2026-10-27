#!/bin/bash

# DESCRIPTION:
# This script validates network device login idle timeout configuration
# following security requirements for automatic session termination
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Extract all login classes defined in the configuration
# 3. Validate each class has an idle-timeout of 1 to 5 minutes
# 4. Check system-wide default idle-timeout is 1 to 5 minutes
#
# STRICT VALIDATION REQUIREMENTS:
# - System default idle-timeout must be at most 5 minutes
# - All login classes must have idle-timeout configured, at most 5 minutes
# - A shorter timeout is stricter and passes
# - Sessions automatically disconnect after at most 5 minutes of inactivity
# - Note: Idle timeout limitation does not apply to super-user class (Junos does not support)
# - Parsed with awk; grep -P is not available everywhere and silently found
#   no classes where it fails
#
# SAMPLE CONFIGURATION:
# set system login idle-timeout 5
# set system login class netadmin idle-timeout 5
# set system login class operation idle-timeout 5
# set system login class super-user-local idle-timeout 5
#
# USAGE:
# ./8003.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: All idle timeouts are configured and at most 5 minutes
# 1 - FAIL: Missing or too long idle timeout configuration

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function valid(minutes) { return minutes ~ /^[0-9]+$/ && minutes >= 1 && minutes <= 5 }

  { sub(/[ \t\r]+$/, "") }
  /^set system login idle-timeout / { global = $5 }
  /^set system login class [^ ]+ / {
    classes[$5] = 1
    if ($6 == "idle-timeout") timeout[$5] = $7
  }

  END {
    if (!valid(global)) exit 1
    for (c in classes) if (!valid(timeout[c])) exit 1
    exit 0
  }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
