# Contributing

## Setup

Go 1.26+ and `bash` (Git Bash on Windows).

```bash
cd checklist
go test ./...                  # unit tests, plus lint of the real catalog and scripts
go vet ./...
go build -o checklist .
cd .. && ./checklist/checklist lint
```

After changing Go code, rebuild both committed binaries:

```bash
cd checklist
GOOS=linux GOARCH=amd64 go build -trimpath -o checklist .
GOOS=windows GOARCH=amd64 go build -trimpath -o checklist.exe .
```

## The catalog: `controls.yaml`

```yaml
platforms:
  ubuntu: {kind: linux, name: Ubuntu, detect: [ubuntu]}
controls:
  - key: linux.ssh.ssh_root_login_disabled
    title: Ensure SSH root login is disabled
    ids: {ubuntu: 1075, debian: 11075, redhat: 2076, rocky: 3076, centos: 5076, suse: 275, oraclelinux: 175}
collectors:
  - key: collect.listening_ports
    title: Non-loopback listening TCP/UDP ports
    ids: {ubuntu: 1098, ..., windows: 4034}
```

- **Keys** (`<family>.<section>.<name>`, or `network.<name>`) never change, so reports and `diff`
  stay comparable.
- **IDs** are script file names (`ubuntu: 1075` is `ubuntu/1075.sh`). They are explicit because
  families do not align by index: Ubuntu and Debian have no separate NIS client control, so from
  the rsh control onward their IDs are one lower than the RHEL index.
- **Platforms** set how scripts run (`linux`/`network` with bash, `windows` with PowerShell) and
  which `/etc/os-release` IDs select them.

## Adding or changing a control

1. Write the script for every platform it applies to. Start from the closest existing check:
   `redhat/` is the reference for the RHEL family (Rocky, CentOS and Oracle Linux are copies;
   SUSE differs in some package names), `ubuntu/` for Debian (Debian is a renamed copy).
2. Add or update the entry in `controls.yaml`: a new key, a title starting with "Ensure", and the
   script ID for each platform.
3. Run `./checklist/checklist docs` to refresh the tables in the platform READMEs, then
   `./checklist/checklist lint`.
4. Add cases that pin the verdict. Network checks can be run against the sample configuration
   in each network directory, and against an empty file (which must fail).
   - Network checks: add configurations to `<platform>/testdata/<id>/` as `pass-<case>.cfg` or
     `fail-<case>.cfg`; `go test ./runner` checks each verdict.
   - Linux checks: add setup scripts to `<platform>/testdata/<id>/` as `pass-<case>.sh` or
     `fail-<case>.sh`. Each runs as root in a new privileged container of the distribution and
     brings it into the state the name promises (install a package, write a configuration file,
     mount a filesystem, set a network sysctl), using the helpers in
     `checklist/runner/testdata/linux-setup.sh`. Debian uses the Ubuntu cases, and Rocky, CentOS,
     Oracle Linux and SUSE use the Red Hat cases, for every control without a `testdata`
     directory of their own. Run one platform with Docker:

     ```bash
     cd checklist
     CHECKLIST_CASES_PLATFORM=ubuntu CHECKLIST_CASES_IMAGE=ubuntu:24.04 \
       go test -count=1 -timeout 60m -run TestLinuxCases ./runner
     ```

     A control that a container cannot exercise (host kernel state) is listed with the reason
     in `notCovered` in `checklist/runner/linux_cases_test.go`; `go test ./runner` fails when a
     control has neither cases nor an entry there. CI runs every platform's cases in its image.

## Policies

Policy files in `policies/` are examples shipped with the project; `checklist lint` loads each one
and rejects unknown control keys, missing reasons and invalid expiry dates. Keep real waivers for a
fleet in that fleet's own repository.

## Output contract

Host checks (`.sh`, `.ps1`) take no arguments:

```text
INFO: /etc/pam.d/system-auth: pam_faillock.so deny=5 (argument)
PASS: Account lockout deny is between 1 and 5 on every pam_faillock/pam_tally2 auth line
```

- Zero or more `INFO:` lines, then exactly one `PASS: <reason>` or `FAIL: <reason>` line, directly
  followed by `exit 0` or `exit 1`.
- Every line on stdout carries one of those prefixes. Print raw command output as detail with
  `echo "$x" | sed 's/^/INFO: /'` before the verdict.

Network checks take the configuration file as their only argument, print exactly `PASS` or `FAIL`
and exit `0` or `1`. An empty or comment-only configuration must fail, and so must a missing
argument or file: print `FAIL`, not a usage or error message (`lint` rejects those).

## Conventions

- English, ASCII only, `#!/bin/bash` on line 1, LF line endings (`.gitattributes` enforces them).
- Exit codes are only `0` and `1`.
- Portable tools only: awk scripts must run under mawk, the default awk on Debian and Ubuntu and
  in the container image, so no `\s`, `\S`, `\b`, three-argument `match()` or `IGNORECASE`; use
  `[[:space:]]` or `[ \t]` and fields. Avoid `grep -P` and `head -n -1`. CI runs the network
  fixtures with mawk.
- Script IDs are identities in downstream systems: never renumber, add new IDs instead.
- Organization-specific values (servers, time zones) are read from `CHECKLIST_*` environment
  variables with a default, not hard-coded.

## Releasing

Push a version tag; the [release workflow](.github/workflows/release.yml) does the rest:

```bash
git tag -a v0.2.0 -m "secbaseline 0.2.0" && git push origin v0.2.0
```

It runs the tests, builds the Linux (amd64, arm64) and Windows (amd64) archives with
`checklist version` set from the tag, publishes them with `checksums.txt` as a GitHub Release, and
pushes a multi-architecture image to `ghcr.io/khanh1916/secbaseline` tagged with the version,
`<major>.<minor>` and `latest`.
