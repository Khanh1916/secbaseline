#!/bin/bash

# Check if talkd package is installed
if dpkg -s talkd 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "talkd package is installed."
  exit 1
fi

# Check if ntalkd package is installed
if dpkg -s ntalkd 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "ntalkd package is installed."
  exit 1
fi

echo "talk packages are not present."
exit 0
