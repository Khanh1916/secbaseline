#!/bin/bash

# DESCRIPTION:
# This script validates network device firewall filter configuration
# following security requirements for access control to management services
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Detect open system services (SSH, Telnet, HTTP, HTTPS, NETCONF over SSH)
#    and their ports; deactivated services do not count
# 3. Find the IPv4 filters applied on interfaces ("filter input <name>" or
#    "filter input-list [ <names> ]")
# 4. For each open service, follow the terms of an applied filter in order,
#    as Junos does, for a packet from an address that no source condition
#    allows: the first term that matches decides; a filter ends with an
#    implicit discard. The service is protected when that packet is
#    discarded or rejected
# 5. The filter must also accept something from a source-address or
#    source-prefix-list (the permitted managers)
#
# Term matching for that packet:
# - A term with source-address / source-prefix-list does not match
#   (except 0.0.0.0/0, which is any address)
# - destination-port / port must include the service port when present
#   (names ssh, telnet, http, https, numbers and ranges)
# - protocol must include tcp when present
# - Terms with other conditions (tcp-established, icmp-type, ...) are skipped
# - A term without a terminating action accepts
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
# 0 - PASS: No open management service, or every one is protected by an applied filter
# 1 - FAIL: An open service is reachable from any address, or the file is unreadable

CONFIG="$1"
if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
  echo "FAIL"
  exit 1
fi

# An empty file (or one holding only comments) is not a configuration.
if ! grep -qvE '^[[:space:]]*([!#].*)?$' "$CONFIG"; then
  echo "FAIL"
  exit 1
fi

if awk '
  function port_number(name) {
    if (name == "ssh") return 22
    if (name == "telnet") return 23
    if (name == "http") return 80
    if (name == "https") return 443
    return name + 0
  }

  function port_matches(list, p,   n, v, i, r) {
    n = split(list, v, " ")
    for (i = 1; i <= n; i++) {
      if (v[i] ~ /^[0-9]+-[0-9]+$/) {
        split(v[i], r, "-")
        if (p >= r[1] + 0 && p <= r[2] + 0) return 1
      } else if (port_number(v[i]) == p) {
        return 1
      }
    }
    return 0
  }

  # Action of the first term that matches a packet to port p from a
  # non-permitted address; "deny" when none matches (implicit discard).
  function stranger(f, p,   n, t, i, key, a) {
    n = split(terms[f], t, " ")
    for (i = 1; i <= n; i++) {
      key = f SUBSEP t[i]
      if ((key in source) || (key in other)) continue
      if ((key in ports) && !port_matches(ports[key], p)) continue
      if ((key in proto) && proto[key] !~ / tcp( |$)/) continue
      a = (key in action) ? action[key] : "accept"
      if (a == "next") continue
      return a
    }
    return "deny"
  }

  function allows_managers(f,   n, t, i, key) {
    n = split(terms[f], t, " ")
    for (i = 1; i <= n; i++) {
      key = f SUBSEP t[i]
      if ((key in source) && (!(key in action) || action[key] == "accept")) return 1
    }
    return 0
  }

  { sub(/[ \t\r]+$/, "") }

  /^deactivate system services / { off[$4 ($4 == "web-management" ? " " $5 : "")] = 1 }

  /^set system services / {
    s = $4
    if (s == "web-management") {
      if ($5 != "http" && $5 != "https") next
      s = $5
      id = "web-management " s
    } else if (s == "netconf") {
      if ($5 != "ssh") next
      id = "netconf"
    } else if (s == "ssh" || s == "telnet") {
      id = s
    } else {
      next
    }
    service[s] = id
    if (!(s in port)) port[s] = (s == "ssh") ? 22 : (s == "telnet") ? 23 : (s == "http") ? 80 : (s == "https") ? 443 : 830
    for (j = 5; j < NF; j++) if ($j == "port") port[s] = $(j + 1)
  }

  /^set interfaces .* family inet filter input/ {
    for (j = 1; j <= NF; j++) {
      if ($j != "input" && $j != "input-list") continue
      for (k = j + 1; k <= NF; k++) if ($k != "[" && $k != "]") applied[$k] = 1
      break
    }
  }

  /^set firewall (family inet )?filter / {
    i = ($3 == "family") ? 6 : 4
    f = $i
    if ($(i + 1) != "term") next
    key = f SUBSEP $(i + 2)
    if (!(key in seen)) { seen[key] = 1; terms[f] = terms[f] " " $(i + 2) }
    values = ""
    for (j = i + 5; j <= NF; j++) if ($j != "[" && $j != "]") values = values " " $j
    if ($(i + 3) == "from") {
      cond = $(i + 4)
      if (cond == "source-address" || cond == "source-prefix-list") {
        if (values !~ / 0\.0\.0\.0\/0( |$)/) source[key] = 1
      } else if (cond == "destination-port" || cond == "port") {
        ports[key] = ports[key] values
      } else if (cond == "protocol") {
        proto[key] = proto[key] values
      } else if (cond != "destination-address" && cond != "destination-prefix-list") {
        other[key] = 1
      }
    } else if ($(i + 3) == "then") {
      a = $(i + 4)
      if (a == "discard" || a == "reject") action[key] = "deny"
      else if (a == "accept") action[key] = "accept"
      else if (a == "next") action[key] = "next"
    }
  }

  END {
    for (s in port) {
      if (service[s] in off) continue
      ok = 0
      for (f in applied) if (stranger(f, port[s] + 0) == "deny" && allows_managers(f)) { ok = 1; break }
      if (!ok) exit 1
    }
    exit 0
  }
' "$CONFIG"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
