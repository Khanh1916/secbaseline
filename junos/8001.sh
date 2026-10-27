#!/bin/bash

# DESCRIPTION:
# This script validates network device configuration by checking hostname settings
# following strict validation logic for proper device identification
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Find the host name, set directly ("set system host-name <name>") or in a
#    configuration group that is applied ("set groups re0 system host-name
#    <name>" with "set apply-groups re0" or "set apply-groups [ re0 re1 ]"),
#    as dual Routing Engine systems do
# 3. A deactivated statement ("deactivate system host-name") does not count
# 4. Validate hostname is not set to default "Amnesiac" value
#
# SAMPLE CONFIGURATION:
# # Example 1: PASS - Properly configured hostname
# set system host-name ROUTER-01
#
# # Example 2: PASS - Host name per Routing Engine
# set groups re0 system host-name ROUTER-01-re0
# set groups re1 system host-name ROUTER-01-re1
# set apply-groups [ re0 re1 ]
#
# # Example 3: FAIL - Default hostname (unconfigured)
# set system host-name Amnesiac
#
# USAGE:
# ./8001.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Hostname is properly configured
# 1 - FAIL: Hostname is not configured or set to default "Amnesiac"

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function usable(name) { return name != "" && name != "Amnesiac" }

  { sub(/[ \t\r]+$/, "") }
  /^deactivate system host-name$/ { deactivated = 1 }
  /^set system host-name / { name = $4 }
  /^set groups [^ ]+ system host-name / { group_name[$3] = $6 }
  /^set apply-groups / {
    for (i = 3; i <= NF; i++) if ($i != "[" && $i != "]") applied[$i] = 1
  }

  END {
    if (!deactivated && usable(name)) exit 0
    for (g in group_name) if ((g in applied) && usable(group_name[g])) exit 0
    exit 1
  }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
