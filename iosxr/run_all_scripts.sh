#!/bin/bash

# DESCRIPTION:
# This script executes all 90xx.sh network validation scripts against a single configuration file
# and reports the PASS/FAILED status for each script along with the script filename
#
# USAGE:
# ./run_90xx_checks.sh <config_file>
#
# PARAMETERS:
# config_file  - Network configuration file (required)
#
# EXIT CODES:
# 0 - All scripts executed successfully (regardless of individual PASS/FAILED results)
# 1 - Error in script execution or missing config file

CONFIG_FILE="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
show_usage() {
    echo "Usage: $0 <config_file>"
    echo ""
    echo "Parameters:"
    echo "  config_file  - Network configuration file (required)"
    echo ""
    echo "Examples:"
    echo "  $0 asr9k.cfg"
    echo "  $0 junos_config.txt"
    echo ""
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

echo -e "${BLUE}=== Network Configuration Validation ===${NC}"
echo "Configuration file: $CONFIG_FILE"
echo "Timestamp: $(date)"
echo ""

# Function to run a script and capture result
run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    local script_args="$2"
    
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
    result=$("$script_path" "$script_args" 2>/dev/null)
    local exit_code=$?
    
    # Check result
    if [[ "$result" == "PASS" ]]; then
        echo -e "${GREEN}$script_name: PASS${NC}"
        passed_scripts=$((passed_scripts + 1))
    elif [[ "$result" == "FAILED" ]] || [[ "$result" == "FAIL" ]]; then
        echo -e "${RED}$script_name: FAILED${NC}"
        failed_scripts=$((failed_scripts + 1))
    else
        echo -e "${YELLOW}$script_name: SKIPPED (unexpected output: '$result')${NC}"
        skipped_scripts=$((skipped_scripts + 1))
    fi
}

# List of scripts to run in the specified order
echo -e "${BLUE}Running network validation scripts...${NC}"
echo ""

# Run all 90xx scripts with config file parameter
run_script "9001.sh" "$CONFIG_FILE"
run_script "9003.sh" "$CONFIG_FILE"
run_script "9005.sh" "$CONFIG_FILE"
run_script "9008.sh" "$CONFIG_FILE"
run_script "9010.sh" "$CONFIG_FILE"
run_script "9012.sh" "$CONFIG_FILE"
run_script "9014.sh" "$CONFIG_FILE"
run_script "9002.sh" "$CONFIG_FILE"
run_script "9004.sh" "$CONFIG_FILE"
run_script "9007.sh" "$CONFIG_FILE"
run_script "9009.sh" "$CONFIG_FILE"
run_script "9011.sh" "$CONFIG_FILE"
run_script "9013.sh" "$CONFIG_FILE"
run_script "9015.sh" "$CONFIG_FILE"

# Summary
echo ""
echo -e "${BLUE}=== Summary ===${NC}"
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

echo ""
echo "Validation completed at: $(date)"

exit 0
