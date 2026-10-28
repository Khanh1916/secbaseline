#!/bin/bash

# No login banner may disclose the operating system: /etc/issue,
# /etc/issue.net, /etc/motd and the file sshd shows (Banner). Fails on getty
# escapes that print system details (\m machine, \r kernel release, \s and \S
# system name, \v version) and on operating system names and terms.
FILES="/etc/issue /etc/issue.net /etc/motd"

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

banner=$(sshd_option banner)
case "$banner" in
  "" | none) ;;
  *) FILES="$FILES $banner" ;;
esac

set -- -e Ubuntu -e Debian -e CentOS -e "Red Hat" -e Fedora -e SUSE -e Rocky -e AlmaLinux -e "Oracle Linux" \
  -e kernel -e release -e version
os_name=$(. /etc/os-release 2>/dev/null && printf '%s' "$NAME")
[ -n "$os_name" ] && set -- "$@" -e "$os_name"

bad=""
for f in $FILES; do
  [ -f "$f" ] || continue
  if grep -q '\\[mrsSv]' "$f" || grep -iqF "$@" "$f"; then
    bad="$bad $f"
  fi
done

if [ -n "$bad" ]; then
  echo "FAIL: Banners disclose operating system information:$bad"
  exit 1
fi

echo "PASS: Banners do not disclose operating system information ($FILES)"
exit 0
