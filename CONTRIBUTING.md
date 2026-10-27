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
   `redhat/` is the reference for the RHEL family (Rocky and CentOS are copies apart from the
   banner check), `ubuntu/` for Debian (Debian is a renamed copy).
2. Add or update the entry in `controls.yaml`: a new key, a title starting with "Ensure", and the
   script ID for each platform.
3. Run `./checklist/checklist docs` to refresh the tables in the platform READMEs, then
   `./checklist/checklist lint`.
4. Run the check on a real or virtual host. Network checks can be run against the sample
   configuration in each network directory, and against an empty file (which must fail).
   For network checks, add cases to `<platform>/testdata/<id>/` as `pass-<case>.cfg` or
   `fail-<case>.cfg`; `go test ./runner` checks each verdict.

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
and exit `0` or `1`. An empty or comment-only configuration must fail.

## Conventions

- English, ASCII only, `#!/bin/bash` on line 1, LF line endings (`.gitattributes` enforces them).
- Exit codes are only `0` and `1`.
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
