#!/bin/bash

if ! rpm -q openldap2 &>/dev/null; then
  echo "package slapd is not installed"
  exit 0
else
  echo "slapd is installed"
  exit 1
fi
