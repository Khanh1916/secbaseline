#!/bin/bash
# Helpers for the setup scripts of the Linux cases (<platform>/testdata/<id>/),
# sourced before each one; see linux_cases_test.go. Setups run as root with
# set -e in a new container. PLATFORM is the platform being tested.

# skip ends the case without a verdict, for a state the image cannot provide.
skip() {
  echo "SKIP: $*" >&2
  exit 77
}

pkg_available() {
  if command -v apt-get >/dev/null; then
    apt-cache policy "$1" 2>/dev/null | grep -q 'Candidate: [^(]'
  elif command -v dnf >/dev/null; then
    dnf -q info "$1" >/dev/null 2>&1
  else
    zypper -n -q search -x -t package "$1" >/dev/null 2>&1
  fi
}

# pkg_install installs packages from the image's repositories, or skips the
# case when one of them is not available there.
pkg_install() {
  local p
  for p in "$@"; do
    pkg_available "$p" || skip "package $p is not available"
  done
  if command -v apt-get >/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "$@" >/dev/null
  elif command -v dnf >/dev/null; then
    dnf -y -q install "$@" >/dev/null
  else
    zypper -n -q install --no-recommends "$@" >/dev/null
  fi
}

# pkg_remove removes those of the packages that are installed (some images
# ship rsyslog, for example); on Debian and Ubuntu their configuration files
# stay behind (dpkg state config-files), as with apt-get remove on a host.
pkg_remove() {
  local p found=()
  for p in "$@"; do
    if command -v dpkg-query >/dev/null; then
      [ "$(dpkg-query -W -f='${db:Status-Status}' "$p" 2>/dev/null)" = installed ] && found+=("$p")
    else
      rpm -q "$p" >/dev/null 2>&1 && found+=("$p")
    fi
  done
  [ ${#found[@]} -gt 0 ] || return 0
  if command -v apt-get >/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get remove -y -qq "${found[@]}" >/dev/null
  elif command -v dnf >/dev/null; then
    dnf -y -q remove "${found[@]}" >/dev/null
  else
    zypper -n -q remove "${found[@]}" >/dev/null
  fi
}

# sshd_config_set replaces /etc/ssh/sshd_config with the given lines, keeping
# the distribution's Include of sshd_config.d where it has one.
sshd_config_set() {
  {
    grep -i '^Include' /etc/ssh/sshd_config 2>/dev/null || true
    printf '%s\n' "$@"
  } >/etc/ssh/sshd_config.new
  mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config
  chmod 600 /etc/ssh/sshd_config
}
