#!/bin/bash

users=$(grep -E "^\w+:[^!*]" /etc/shadow 2>/dev/null | cut -d: -f1)

if [ -z "$users" ]; then
  echo "No users with passwords found."
  exit 1
fi

for user in $users; do
  if sudo chage -l "$user" 2>/dev/null | grep -E "^Password expires\s*:.*never$" &>/dev/null; then
    echo "User $user has Password expires set to 'never'."
    exit 1
  fi
done

echo "All users have Password expires set to a specific date."
exit 0
