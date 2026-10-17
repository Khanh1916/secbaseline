#!/bin/bash

# Check if firewall rules exist for all open ports
if ! command -v firewall-cmd &> /dev/null; then
  echo "Missing rules or open ports not protected."
  exit 1
fi

# Get firewall rules
firewall_rules=$(firewall-cmd --list-all 2>/dev/null)
if [ $? -ne 0 ]; then
  echo "Missing rules or open ports not protected."
  exit 1
fi

# Get open ports (listening ports)
open_ports=$(ss -tuln | awk 'NR>1 {print $5}' | grep -oE '[0-9]+$' | sort -u)

# Check if firewall has rules for open ports
missing_rules=false

for port in $open_ports; do
  # Skip common local ports
  if [ "$port" -eq 25 ] || [ "$port" -eq 53 ] || [ "$port" -eq 123 ]; then
    continue
  fi
  
  # Check if port is in firewall rules
  if ! echo "$firewall_rules" | grep -q "$port"; then
    echo "Port $port is open but not in firewall rules."
    missing_rules=true
  fi
done

if [ "$missing_rules" = true ]; then
  echo "Missing rules or open ports not protected."
  exit 1
fi

echo "Rules match open ports."
exit 0
