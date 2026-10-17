# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A library of security-hardening compliance checks (CIS-benchmark style) for Linux distros, Windows, and network devices, plus a small Go binary (`checklist/`) that collects inventory/baseline data. There is no runner or reporting layer here: an external system invokes each check **by numeric ID** and reads its stdout + exit code. The filename *is* the control ID, so never rename or renumber a file casually.

## Check contracts

**Host checks** (`ubuntu/ debian/ redhat/ rocky/ centos/ suse/ oraclelinux/` as `.sh`, `windows/` as `.ps1`)
- Run directly on the target host, usually as root/Administrator, with no arguments.
- Print a human-readable message, then `exit 0` = pass, `exit 1` = fail. Only 0/1 are allowed (exit 2 was deliberately replaced by 1).
- Message language is mixed: many Ubuntu/Debian scripts print Vietnamese `pass:`/`fail:` lines, the rest print English sentences. The exit code is the verdict, not the text.

**Network-device checks** (`iosxe/ junos/ iosxr/ nxos/`)
- Offline: they take one argument, a saved device config file, and never touch a device.
- Print exactly `PASS` or `FAILED` on stdout (the `*_run_all.sh` runners treat anything else as SKIPPED; the iosxr runner also accepts `FAIL`), exit 0/1.
- Each directory ships a sample config (`iosxe.cfg`, `cat8k.cfg`, `jsw.cfg`, `asr9k.cfg`, `n9k.cfg`) for testing.
- Control index 6 (`7006`, `8006`, `9006`, `10006`) is intentionally absent on every platform; the runners skip it.

## ID scheme

The same control index `k` means the same control across sibling platforms, so a fix to one control usually has to be mirrored at the same `k` in the other directories:

| Platform | Script IDs | Formula |
|---|---|---|
| ubuntu | 1001–1090 | 1000+k |
| debian | 11001–11090 (copied from ubuntu via `debian/rename.sh`) | 11000+k |
| redhat | 2001–2091 | 2000+k |
| rocky | 3001–3091 | 3000+k |
| centos | 5001–5091 | 5000+k |
| suse | 200–290 | 199+k |
| oraclelinux | 100–190 | 99+k |
| windows | 4001–4026 | — |
| iosxe / junos / iosxr / nxos | 7001–7015 / 8001–8015 / 9001–9015 / 10001–10015 | 7000+k … 10000+k |

IDs just past each platform's script range are served by the Go binary instead of a script (see below).

The RHEL-family and SUSE/Oracle directories were cloned from each other, and recent commits ("fix rocky os", "fix centos os", "rocky - id checklist 2047") are about re-aligning them. When editing, watch for leftovers from the source distro: wrong OS name in banner checks (index 30), `rpm` vs `dpkg`, or a different control sitting at the same index. The latest CentOS fix copied `redhat/` scripts over, so compare against `redhat/` first.

## Go collector (`checklist/`)

A cobra CLI, `checklist <id> [-F file1,file2] [-f dir1,dir2]`. `main.go` is a single `switch` mapping every platform's ID for a collector to the same function, e.g. `1091`/`11091`/`2092`/`3092`/`5092`/`291`/`1`/`4027` → SSH authorized_keys. The ten collectors, in order: ssh keys, accounts, users/groups (+sudoers), password policy, patching (OS/kernel), SHA-256 file checksums (`-F`), file listing (`-f`), non-loopback listening ports, firewall rules (`sudo iptables`/`ip6tables`), log config (rsyslog + `kesl.service` status).

- Output is plain text, **sorted** so it is deterministic across runs (the consumer diffs it against a baseline). Keep new output sorted and stable.
- OS-specific code uses filename build constraints: `*_linux.go`, `*_windows.go`, `*_darwin.go`. The darwin files are stubs returning `""`. A new OS-specific collector needs all three files or the other platforms won't compile.
- Adding a collector means adding a new `case` with the next ID for **every** platform in `main.go`.
- `checklist/checklist` (linux/amd64 ELF) and `checklist/checklist.exe` (windows/amd64) are committed build outputs; rebuild both when Go sources change.

## Commands

There are no tests and no linter config. Go is installed locally; shellcheck is not.

```bash
# Go: vet, and confirm all OS build-tag variants compile
cd checklist && go vet ./...
cd checklist && for os in linux windows darwin; do GOOS=$os go build -o /dev/null . ; done

# Go: rebuild the committed binaries
cd checklist && GOOS=linux GOARCH=amd64 go build -o checklist .
cd checklist && GOOS=windows GOARCH=amd64 go build -o checklist.exe .

# Go: run one collector
./checklist 1091
./checklist 1096 -F /etc/passwd,/etc/ssh/sshd_config
./checklist 1097 -f /etc/cron.d,/etc/sudoers.d

# Single host check (on the target machine); verdict is the exit code
sudo bash ubuntu/1005.sh; echo $?
powershell -ExecutionPolicy Bypass -File windows\4001.ps1

# Single network check, or a whole platform against its sample config
bash iosxe/7001.sh iosxe/iosxe.cfg
bash iosxe/iosxe_run_all.sh iosxe/iosxe.cfg   # also junos/junos_run_all.sh, nxos/nxos_run_all.sh, iosxr/run_all_scripts.sh
```

## Pitfalls

- **Line endings.** The repo is edited on Windows with `core.autocrlf=true` and has no `.gitattributes`; some `.sh` files are stored with CRLF. CRLF breaks bash on the target (`$'\r': command not found`). Keep `.sh` files LF. Check with `git ls-files --eol | grep crlf`.
- **Shebang must be line 1.** Several scripts start with a blank line, and a couple have `#!/bin/bash` glued onto the end of a comment line. Find them with `for f in $(git ls-files '*.sh'); do head -n1 "$f" | grep -q '^#!' || echo "$f"; done`.
- Every host script must end on an explicit `exit 0`/`exit 1`; a missing exit returns whatever the last command returned.
- `iosxr/execution_log.txt` is a leftover run log, not an input.
