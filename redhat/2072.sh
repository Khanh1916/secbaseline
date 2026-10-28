#!/bin/bash

# OpenSSH 7.4 and later speak only protocol 2 and ignore Protocol, so this
# fails only when the configuration asks for protocol 1.
SSHD_CONFIG=/etc/ssh/sshd_config

# sshd_option KEYWORD prints the value sshd uses for KEYWORD outside Match
# blocks, as sshd reads it: the first value wins, Include files are read in
# place (in sorted order), keywords are case-insensitive, and everything after
# the first Match line applies only to some connections.
sshd_option() {
  sshd_option_in "$SSHD_CONFIG" "$(echo "$1" | tr 'A-Z' 'a-z')"
  [ $? -eq 0 ]
}

# sshd_option_in FILE KEYWORD returns 0 when found, 1 when not, 2 at a Match line.
sshd_option_in() {
  local file=$1 key=$2 kw val pattern inc rc
  [ -r "$file" ] || return 1
  while read -r kw val; do
    case "$kw" in
      match) return 2 ;;
      include)
        for pattern in $val; do
          case "$pattern" in
            /*) ;;
            *) pattern=/etc/ssh/$pattern ;;
          esac
          for inc in $pattern; do
            [ -f "$inc" ] || continue
            sshd_option_in "$inc" "$key"
            rc=$?
            [ $rc -ne 1 ] && return $rc
          done
        done
        ;;
      "$key")
        printf '%s\n' "$val"
        return 0
        ;;
    esac
  done < <(awk '{
      sub(/#.*/, ""); sub(/^[ \t]+/, ""); sub(/[ \t]+$/, "")
      if ($0 == "") next
      kw = $0; sub(/[ \t=].*/, "", kw)
      val = substr($0, length(kw) + 1); sub(/^[ \t]*=?[ \t]*/, "", val)
      print tolower(kw), val
    }' "$file")
  return 1
}

if [ ! -f "$SSHD_CONFIG" ]; then
  echo "FAIL: $SSHD_CONFIG does not exist"
  exit 1
fi

protocol=$(sshd_option protocol)
echo "INFO: Protocol ${protocol:-not set}"

case ",$protocol," in
  *,1,*)
    echo "FAIL: sshd is configured to accept protocol 1 (Protocol $protocol)"
    exit 1
    ;;
esac

echo "PASS: sshd uses protocol 2 only"
exit 0
