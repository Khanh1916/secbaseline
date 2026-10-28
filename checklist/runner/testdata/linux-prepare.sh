#!/bin/bash
# Prepares a distribution image for the Linux cases (see linux_cases_test.go):
# installs the tools every server has but minimal container images leave out
# (on SUSE, findmnt comes with util-linux-systemd),
# creates SSH host keys as the first start of sshd would, and keeps the package
# metadata so that cases can install packages quickly.
set -e
if command -v apt-get >/dev/null; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends procps iproute2 kmod systemd openssh-server \
    passwd login util-linux findutils >/dev/null
elif command -v dnf >/dev/null; then
  dnf -y -q install procps-ng iproute kmod systemd openssh-server passwd util-linux findutils \
    shadow-utils >/dev/null
  dnf -q makecache >/dev/null
elif command -v zypper >/dev/null; then
  zypper -n -q refresh
  zypper -n -q install --no-recommends procps iproute2 kmod systemd openssh-server shadow \
    util-linux util-linux-systemd findutils >/dev/null
else
  echo "no supported package manager" >&2
  exit 1
fi
ssh-keygen -A
