#!/bin/bash

# Cisco IOS-XE Configuration AAA Remote Authentication Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate AAA remote authentication configuration for console and VTY access
# Ensures proper RADIUS/TACACS+ authentication setup and console/VTY line compliance
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7008.sh <config_file>
# Example: ./7008.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Validation Logic:
# 
# 1. AAA Model Check:
#    - If "aaa new-model" not configured -> FAIL (no centralized AAA;
#      every line authenticates locally or with a line password)
#
# 2. Remote Authentication Method Detection:
#    - Server groups: the built-in "radius" and "tacacs+", and named groups
#      defined with "aaa group server radius|tacacs+ <name>"
#    - A method list is central when its first method is "group <server group>":
#      "aaa authentication login <list> group <group> [...]"
#
# 3. VTY Line Validation:
#    - All line vty blocks must use: "login authentication <method>"
#    - Method name must match one defined in AAA configuration; a block
#      without "login authentication" uses the "default" list
#    - No line vty block -> FAIL
#    - Ensures consistent remote authentication across all VTY sessions
#
# 4. Console Validation (as on IOS XR and NX-OS):
#    - line con 0 must use a central list too: its own "login authentication
#      <list>", otherwise the "default" list
#    - A list such as "group TACGRP local" still lets the local database in
#      when the servers do not answer, so the console stays usable
#
# Security Compliance:
# - Enforces centralized authentication via RADIUS/TACACS+
# - Prevents local authentication bypass on remote access
# - Ensures all VTY lines use the same authentication policy
# - Supports enterprise identity management integration
#
# Common Failure Scenarios:
# - AAA method defined but VTY lines not configured
# - Method name mismatch between AAA definition and VTY usage
# - Missing "login authentication" on some VTY lines
# - Console using a local-only list, or the default list when it is not central
# - RADIUS/TACACS+ method not properly defined
#
# Return Codes:
# 0 = PASS (AAA remote authentication properly configured)
# 1 = FAIL (missing or inconsistent AAA configuration)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses AWK for multi-line VTY block parsing
# - Supports both RADIUS and TACACS+ authentication groups
# - Pattern matching handles standard IOS-XE syntax variations
# - Validates method name consistency across configuration

config_file="$1"

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAIL"
  exit 1
fi

# Without aaa new-model there is no centralized AAA
if ! grep -qE '^aaa new-model([[:space:]]|$)' "$config_file"; then
  echo "FAIL"
  exit 1
fi

# Read the file twice: server groups and method lists may appear in any order,
# then the console and every line vty block must use a central method list
if awk '
  NR == FNR {
    if ($0 ~ /^aaa group server (radius|tacacs\+) /) groups[$5] = 1
    if ($0 ~ /^aaa authentication login /) { first[$4] = $5; group[$4] = $6 }
    next
  }

  function central(list,   g) {
    if (!(list in first) || first[list] != "group") return 0
    g = group[list]
    return g == "radius" || g == "tacacs+" || (g in groups)
  }

  function close_block() {
    if (!in_block) return
    if (!central(list == "" ? "default" : list)) bad++
    in_block = 0
  }

  /^line con / {
    close_block()
    in_console = 1
    next
  }

  /^line vty/ {
    close_block()
    in_console = 0
    in_block = 1
    blocks++
    list = ""
    next
  }

  /^[^ ]/ {
    close_block()
    in_console = 0
  }

  in_console && /^ +login authentication / {
    console_list = $3
  }

  in_block && /^ +login authentication / {
    list = $3
  }

  END {
    close_block()
    if (!central(console_list == "" ? "default" : console_list)) bad++
    exit (blocks == 0 || bad > 0) ? 1 : 0
  }
' "$config_file" "$config_file"; then
  echo "PASS"
  exit 0
else
  echo "FAIL"
  exit 1
fi
