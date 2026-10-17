#!/bin/bash

# DESCRIPTION:
# This script executes all 100xx.sh security validation scripts against a single configuration file
# and reports the PASS/FAILED status for each script along with the script filename
#
# USAGE:
# ./nxos_run_all.sh <config_file>
#
# PARAMETERS:
# config_file  - NX-OS configuration file (required)
#
# EXIT CODES:
# 0 - All scripts executed successfully (regardless of individual PASS/FAILED results)
# 1 - Error in script execution or missing config file

CONFIG_FILE="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
show_usage() {
    echo "Usage: $0 <config_file>"
    echo ""
    echo "Parameters:"
    echo "  config_file  - NX-OS configuration file (required)"
    echo ""
    echo "Examples:"
    echo "  $0 n9k-config.txt"
    echo "  $0 /path/to/nx-os-config.cfg"
}

# Validate input parameters
if [[ -z "$CONFIG_FILE" ]]; then
    echo -e "${RED}ERROR: Configuration file is required${NC}"
    show_usage
    exit 1
fi

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}ERROR: Configuration file '$CONFIG_FILE' not found${NC}"
    exit 1
fi

# Check if config file is readable
if [[ ! -r "$CONFIG_FILE" ]]; then
    echo -e "${RED}ERROR: Configuration file '$CONFIG_FILE' is not readable${NC}"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Initialize counters
total_scripts=0
passed_scripts=0
failed_scripts=0
skipped_scripts=0

echo -e "${YELLOW}=== NX-OS Security Configuration Validation ===${NC}"
echo "Configuration file: $CONFIG_FILE"
echo "Timestamp: $(date)"
echo ""

# Function to run a script and capture result
run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    shift
    local script_args="$@"
    
    total_scripts=$((total_scripts + 1))
    
    if [[ ! -f "$script_path" ]]; then
        echo -e "${YELLOW}$script_name: SKIPPED (script not found)${NC}"
        skipped_scripts=$((skipped_scripts + 1))
        return
    fi
    
    if [[ ! -x "$script_path" ]]; then
        chmod +x "$script_path" 2>/dev/null
        if [[ ! -x "$script_path" ]]; then
            echo -e "${YELLOW}$script_name: SKIPPED (not executable)${NC}"
            skipped_scripts=$((skipped_scripts + 1))
            return
        fi
    fi
    
    # Run the script and capture output
    local result
    result=$("$script_path" $script_args 2>/dev/null)
    local exit_code=$?
    
    # Check result
    if [[ "$result" == "PASS" ]]; then
        echo -e "${GREEN}$script_name: PASS${NC}"
        passed_scripts=$((passed_scripts + 1))
    elif [[ "$result" == "FAILED" ]]; then
        echo -e "${RED}$script_name: FAILED${NC}"
        failed_scripts=$((failed_scripts + 1))
    else
        echo -e "${YELLOW}$script_name: SKIPPED (unexpected output: '$result')${NC}"
        skipped_scripts=$((skipped_scripts + 1))
    fi
}

# List of scripts to run with their parameters
echo -e "${YELLOW}Running security validation scripts...${NC}"
echo ""

# Scripts that only need config file (excluding 10006.sh as requested)
run_script "10001.sh" "$CONFIG_FILE"
run_script "10002.sh" "$CONFIG_FILE"
run_script "10003.sh" "$CONFIG_FILE"
run_script "10004.sh" "$CONFIG_FILE"
run_script "10005.sh" "$CONFIG_FILE"
# 10006.sh is excluded as requested
run_script "10007.sh" "$CONFIG_FILE"
run_script "10008.sh" "$CONFIG_FILE"
run_script "10009.sh" "$CONFIG_FILE"
run_script "10010.sh" "$CONFIG_FILE"
run_script "10011.sh" "$CONFIG_FILE"
run_script "10012.sh" "$CONFIG_FILE"
run_script "10013.sh" "$CONFIG_FILE"
run_script "10014.sh" "$CONFIG_FILE"
run_script "10015.sh" "$CONFIG_FILE"

# Summary
echo ""
echo -e "${YELLOW}=== Summary ===${NC}"
echo "Total scripts: $total_scripts"
echo -e "${GREEN}Passed: $passed_scripts${NC}"
echo -e "${RED}Failed: $failed_scripts${NC}"
echo -e "${YELLOW}Skipped: $skipped_scripts${NC}"
echo ""

# Calculate success rate
if [[ $((passed_scripts + failed_scripts)) -gt 0 ]]; then
    success_rate=$(( (passed_scripts * 100) / (passed_scripts + failed_scripts) ))
    echo "Success rate: ${success_rate}% (${passed_scripts}/$((passed_scripts + failed_scripts)))"
fi

# Overall result
if [[ $failed_scripts -eq 0 && $passed_scripts -gt 0 ]]; then
    echo -e "${GREEN}Overall: PASS - All executed scripts passed${NC}"
elif [[ $failed_scripts -gt 0 ]]; then
    echo -e "${RED}Overall: FAILED - $failed_scripts script(s) failed${NC}"
else
    echo -e "${YELLOW}Overall: NO RESULTS - No scripts executed successfully${NC}"
fi

exit 0