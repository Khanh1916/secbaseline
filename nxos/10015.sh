#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# backup scheduler configuration is enabled for automated config backups.
#
# VALIDATION CRITERIA:
# - Must have "feature scheduler" enabled
# - Must have scheduler job with "copy running-config" to supported protocols
# - Must have scheduler schedule with time and valid job reference
# - Job referenced in schedule must exist and be valid
#
# USAGE:
# ./10015.sh <config_file>
#
# EXAMPLES:
# ./10015.sh router-config.txt
# ./10015.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# feature scheduler
# scheduler job name BACKUP-TFTP
#  copy running-config tftp://192.168.89.104/$(SWITCHNAME)-cfg.$(TIMESTAMP) vrf management
# end-job
# scheduler schedule name BACKUP-DAILY
#  job name BACKUP-TFTP
#  time daily 23:00
#
# EXIT CODES:
# 0 - PASS: Backup scheduler is properly configured
# 1 - FAILED: Backup scheduler is not properly configured
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, awk utilities (standard on most Unix/Linux systems)

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

# Function to check feature scheduler
check_feature_scheduler() {
    if grep -qi "^feature[[:space:]]\+scheduler[[:space:]]*$" "$CONFIG_FILE"; then
        echo "SCHEDULER_ENABLED"
    else
        echo "SCHEDULER_DISABLED"
    fi
}

# Function to extract and validate scheduler jobs
check_scheduler_jobs() {
    local valid_jobs=()
    local all_jobs=()
    
    # Extract all scheduler job blocks using AWK
    local job_info=$(awk '
    BEGIN { 
        in_job_block = 0
        job_name = ""
        has_copy_command = 0
    }
    
    # Job block start
    /^scheduler[[:space:]]+job[[:space:]]+name/ {
        # Save previous job if any
        if (job_name != "") {
            print job_name ":" (has_copy_command ? "VALID" : "INVALID")
        }
        
        in_job_block = 1
        job_name = $4
        has_copy_command = 0
        next
    }
    
    # Job block end
    in_job_block && (/^end-job/ || /^[[:space:]]*$/) {
        in_job_block = 0
    }
    
    # Check for copy running-config in job block
    in_job_block && /^[[:space:]]+copy[[:space:]]+running-config[[:space:]]+(tftp|ftp|http|https|scp|sftp|usb)/ {
        has_copy_command = 1
    }
    
    END {
        # Handle last job
        if (job_name != "") {
            print job_name ":" (has_copy_command ? "VALID" : "INVALID")
        }
    }
    ' "$CONFIG_FILE")
    
    if [ -z "$job_info" ]; then
        echo "NO_JOBS_FOUND"
        return
    fi
    
    # Process job info
    local has_valid_job=false
    while IFS=':' read -r job_name job_status; do
        if [ -n "$job_name" ]; then
            all_jobs+=("$job_name")
            if [ "$job_status" = "VALID" ]; then
                valid_jobs+=("$job_name")
                has_valid_job=true
            fi
        fi
    done <<< "$job_info"
    
    if [ "$has_valid_job" = true ]; then
        echo "VALID_JOBS_FOUND:${valid_jobs[*]}"
    else
        echo "NO_VALID_JOBS_FOUND"
    fi
}

# Function to extract and validate scheduler schedules
check_scheduler_schedules() {
    local valid_schedules=()
    local schedule_jobs=()
    
    # Extract all scheduler schedule blocks using AWK
    local schedule_info=$(awk '
    BEGIN { 
        in_schedule_block = 0
        schedule_name = ""
        has_time = 0
        job_name = ""
    }
    
    # Schedule block start
    /^scheduler[[:space:]]+schedule[[:space:]]+name/ {
        # Save previous schedule if any
        if (schedule_name != "") {
            print schedule_name ":" job_name ":" (has_time && job_name != "" ? "VALID" : "INVALID")
        }
        
        in_schedule_block = 1
        schedule_name = $4
        has_time = 0
        job_name = ""
        next
    }
    
    # Schedule block end - line not indented or empty line
    in_schedule_block && (/^[^[:space:]]/ || /^[[:space:]]*$/) {
        # Check if this line starts a new block
        if (/^scheduler[[:space:]]+schedule[[:space:]]+name/) {
            # This is handled above, do not end block here
        } else {
            in_schedule_block = 0
        }
    }
    
    # Check for time configuration in schedule block
    in_schedule_block && /^[[:space:]]+time[[:space:]]+(daily|weekly|monthly|start)/ {
        has_time = 1
    }
    
    # Check for job name in schedule block
    in_schedule_block && /^[[:space:]]+job[[:space:]]+name[[:space:]]+/ {
        job_name = $3
    }
    
    END {
        # Handle last schedule
        if (schedule_name != "") {
            print schedule_name ":" job_name ":" (has_time && job_name != "" ? "VALID" : "INVALID")
        }
    }
    ' "$CONFIG_FILE")
    
    if [ -z "$schedule_info" ]; then
        echo "NO_SCHEDULES_FOUND"
        return
    fi
    
    # Process schedule info
    local has_valid_schedule=false
    while IFS=':' read -r schedule_name job_name schedule_status; do
        if [ -n "$schedule_name" ]; then
            if [ "$schedule_status" = "VALID" ]; then
                valid_schedules+=("$schedule_name")
                schedule_jobs+=("$job_name")
                has_valid_schedule=true
            fi
        fi
    done <<< "$schedule_info"
    
    if [ "$has_valid_schedule" = true ]; then
        echo "VALID_SCHEDULES_FOUND:${valid_schedules[*]}:${schedule_jobs[*]}"
    else
        echo "NO_VALID_SCHEDULES_FOUND"
    fi
}

# Function to cross-reference jobs and schedules
cross_reference_jobs_schedules() {
    local valid_jobs_list="$1"
    local schedule_jobs_list="$2"
    
    # Check if any job referenced in schedules exists in valid jobs
    for schedule_job in $schedule_jobs_list; do
        local job_found=false
        for valid_job in $valid_jobs_list; do
            if [ "$schedule_job" = "$valid_job" ]; then
                job_found=true
                break
            fi
        done
        
        if [ "$job_found" = false ]; then
            echo "JOB_REFERENCE_INVALID"
            return
        fi
    done
    
    echo "ALL_JOB_REFERENCES_VALID"
}

# Initialize validation status
failed=false
failure_reasons=()

# Step 1: Check feature scheduler (MANDATORY - fail fast)
scheduler_feature_status=$(check_feature_scheduler)

if [ "$scheduler_feature_status" != "SCHEDULER_ENABLED" ]; then
    failed=true
    failure_reasons+=("Feature scheduler is not enabled")
    
    # Output results immediately for fail-fast
    echo "FAILED"
    exit 1
fi

# Step 2: Check scheduler jobs
jobs_status=$(check_scheduler_jobs)

if [[ "$jobs_status" == "VALID_JOBS_FOUND:"* ]]; then
    valid_jobs_list="${jobs_status#VALID_JOBS_FOUND:}"
else
    failed=true
    case "$jobs_status" in
        "NO_JOBS_FOUND")
            failure_reasons+=("No scheduler jobs found")
            ;;
        "NO_VALID_JOBS_FOUND")
            failure_reasons+=("No valid scheduler jobs with copy running-config found")
            ;;
    esac
fi

# Step 3: Check scheduler schedules
schedules_status=$(check_scheduler_schedules)

if [[ "$schedules_status" == "VALID_SCHEDULES_FOUND:"* ]]; then
    # Parse the result: VALID_SCHEDULES_FOUND:schedule1 schedule2:job1 job2
    temp="${schedules_status#VALID_SCHEDULES_FOUND:}"
    valid_schedules_list="${temp%:*}"
    schedule_jobs_list="${temp##*:}"
else
    failed=true
    case "$schedules_status" in
        "NO_SCHEDULES_FOUND")
            failure_reasons+=("No scheduler schedules found")
            ;;
        "NO_VALID_SCHEDULES_FOUND")
            failure_reasons+=("No valid scheduler schedules with time and job name found")
            ;;
    esac
fi

# Step 4: Cross-reference validation (only if both jobs and schedules are valid)
if [ "$failed" = false ]; then
    cross_ref_status=$(cross_reference_jobs_schedules "$valid_jobs_list" "$schedule_jobs_list")
    
    case "$cross_ref_status" in
        "JOB_REFERENCE_INVALID")
            failed=true
            failure_reasons+=("Schedule references invalid or non-existent job")
            ;;
        "ALL_JOB_REFERENCES_VALID")
            # All validations passed
            ;;
    esac
fi

# Output results
if [ "$failed" = true ]; then
    echo "FAILED"
    exit 1
else
    echo "PASS"
    exit 0
fi