#!/bin/bash

# Policy (CIS): accounts lock after 1 to 5 consecutive failed logins.
# Every active auth line using pam_faillock.so or pam_tally2.so is checked.
# pam_faillock.so takes deny from its arguments, else from faillock.conf,
# else its built-in default of 3; pam_tally2.so must set deny explicitly.
MIN_DENY=1
MAX_DENY=5

FILES=(
  /etc/pam.d/system-auth
  /etc/pam.d/password-auth
  /etc/pam.d/common-auth
  /etc/pam.d/login
  /etc/pam.d/sshd
)
FAILLOCK_CONF=/etc/security/faillock.conf

conf_deny=""
if [ -f "$FAILLOCK_CONF" ]; then
  conf_deny=$(awk -F= '/^[[:space:]]*deny[[:space:]]*=/ {v = $2; sub(/#.*/, "", v); gsub(/[[:space:]]/, "", v)} END {print v}' "$FAILLOCK_CONF")
  [ -n "$conf_deny" ] && echo "INFO: $FAILLOCK_CONF deny=$conf_deny"
fi

found=0
bad=""
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  while IFS= read -r line; do
    found=1
    module=$(echo "$line" | grep -oE 'pam_(faillock|tally2)\.so' | head -n1)
    deny=$(echo "$line" | grep -oE '(^|[[:space:]])deny=[0-9]+' | tail -n1 | cut -d= -f2)
    source="argument"
    if [ -z "$deny" ] && [ "$module" = "pam_faillock.so" ]; then
      if [ -n "$conf_deny" ]; then
        deny=$conf_deny
        source="$FAILLOCK_CONF"
      else
        deny=3
        source="module default"
      fi
    fi
    echo "INFO: $f: $module deny=${deny:-unset} ($source)"
    if ! [[ "$deny" =~ ^[0-9]+$ ]] || [ "$deny" -lt "$MIN_DENY" ] || [ "$deny" -gt "$MAX_DENY" ]; then
      entry="$f:$module:deny=${deny:-unset}"
      case " $bad " in
        *" $entry "*) ;;
        *) bad="$bad $entry" ;;
      esac
    fi
  done < <(grep -E '^[[:space:]]*-?auth[[:space:]].*pam_(faillock|tally2)\.so' "$f")
done

if [ $found -eq 0 ]; then
  echo "FAIL: No pam_faillock.so or pam_tally2.so auth line found"
  exit 1
fi

if [ -n "$bad" ]; then
  echo "FAIL: Account lockout deny must be between $MIN_DENY and $MAX_DENY; found:$bad"
  exit 1
fi

echo "PASS: Account lockout deny is between $MIN_DENY and $MAX_DENY on every pam_faillock/pam_tally2 auth line"
exit 0
