# checklist (Go CLI)

`checklist` is the single binary that drives this repository. It runs the platform scripts and
turns their output into a report, collects host inventory, and checks that the catalog and the
scripts follow the repository's conventions.

| Command | What it does |
|---|---|
| `checklist run` | Run every check (and collector) for one platform; write a JSON report and optionally HTML |
| `checklist report <file.json>` | Render a saved JSON report as a self-contained HTML page |
| `checklist diff <old.json> <new.json>` | Compare two reports: regressions, fixes, other status changes and inventory drift |
| `checklist serve` | Web dashboard that receives reports from `run --upload` and tracks every host over time |
| `checklist lint` | Validate `controls.yaml`, the scripts' output contract and the README tables |
| `checklist docs` | Regenerate the control tables in each platform README from `controls.yaml` |
| `checklist <id>` | Run one inventory collector and print its raw output (the original interface) |
| `checklist version` | Print the build version |

## Build

Requires Go 1.24 or newer.

```bash
cd checklist
go build -o checklist .                                   # this machine
GOOS=linux   GOARCH=amd64 go build -o checklist .         # Linux binary
GOOS=windows GOARCH=amd64 go build -o checklist.exe .     # Windows binary
go build -ldflags "-X main.version=1.2.0" -o checklist .  # stamp a version
```

`checklist` (linux/amd64) and `checklist.exe` (windows/amd64) are committed so the repository can
be copied to a server and used without a Go toolchain. Rebuild both when the Go code changes.

## `checklist run`

```bash
# On a Linux host: detect the distribution, run all checks and collectors
sudo ./checklist/checklist run --html report.html -o report.json

# Audit a saved network device configuration
./checklist/checklist run -p iosxe -c running-config.txt --html audit.html

# Only SSH and authentication controls, no collectors
sudo ./checklist/checklist run --only linux.ssh,linux.auth --no-collectors
```

| Flag | Default | Meaning |
|---|---|---|
| `-p, --platform` | detected | Platform key from `controls.yaml`. Linux is detected from `/etc/os-release` (`ID`, then `ID_LIKE`), Windows from the OS. Required for network platforms. |
| `-c, --config` | | Saved device configuration to audit. Network platforms only. |
| `-o, --output` | `-` (stdout) | Where to write the JSON report. |
| `--html` | | Also write an HTML report to this path. |
| `--only` | all | Comma-separated key prefixes, e.g. `linux.ssh,collect.listening_ports`. |
| `-j, --jobs` | `4` | Checks run in parallel. |
| `--timeout` | `2m` | Per-check timeout; a check that runs longer is reported as `error`. |
| `--no-collectors` | false | Skip inventory collectors. |
| `-F, --files` / `-f, --folders` | | Inputs for the checksum and file-listing collectors; without them those collectors are `skipped`. |
| `--shell` | `bash` | Interpreter for `.sh` scripts (useful on Windows: point it at Git Bash). |
| `--upload` | | Send the report to a dashboard started with `checklist serve`, e.g. `http://dashboard:8080`. |
| `--token` | `$CHECKLIST_SERVER_TOKEN` | Token for `--upload`. |
| `--root` | auto | Repository root. By default the current directory, its parent, the binary's directory and its parent are searched for `controls.yaml`. |

The runner prints a one-line summary to stderr and exits `0` when the run completed, whatever the
checks found. It exits `1` only when the run itself could not proceed.

### How a check result is decided

Every script follows the output contract described in the [contributing guide](../CONTRIBUTING.md#output-contract).
The runner reads the last `PASS`/`FAIL` line of stdout, collects `INFO:` lines as details, and
requires the exit code to agree:

| Exit code | Verdict line | Status |
|---|---|---|
| 0 | `PASS…` | `pass` |
| 1 | `FAIL…` | `fail` |
| anything else, or a disagreement, or a timeout | | `error` (raw stdout and stderr are kept in the report) |

Scripts run with `LC_ALL=C` so the command output they parse is in English, with the platform
directory as working directory. Output is capped at 1 MiB per stream.

## Report format

`checklist run` writes one JSON document (`schema_version` changes only on incompatible changes):

```json
{
  "schema_version": 1,
  "tool": { "name": "checklist", "version": "1.0.0" },
  "platform": { "key": "ubuntu", "name": "Ubuntu", "kind": "linux" },
  "host": { "hostname": "web01", "os": "linux", "platform": "ubuntu", "platform_version": "24.04", "arch": "amd64" },
  "started_at": "2026-10-17T08:20:02Z",
  "summary": { "total": 90, "pass": 71, "fail": 18, "error": 1, "score": 79.8 },
  "checks": [
    { "key": "linux.filesystem.var_tmp_partition", "id": "1013", "title": "Ensure /var/tmp is a separate partition or bound to /tmp",
      "section": "filesystem", "status": "fail", "message": "/var/tmp is not a symlink to /tmp",
      "details": ["drwxrwxrwt 2 root root 4096 Oct 17 08:00 /var/tmp"], "exit_code": 1, "duration_ms": 4 }
  ],
  "collectors": [
    { "key": "collect.listening_ports", "id": "1098", "title": "Non-loopback listening TCP/UDP ports", "status": "ok", "output": "0.0.0.0:22/TCP" }
  ]
}
```

- Check `status`: `pass`, `fail` or `error` (errors keep raw `output` and `stderr`). Collector
  `status`: `ok`, `error` or `skipped`.
- `score` is `pass / (pass + fail)` as a percentage; errors are excluded.
- Network reports add `target`: the configuration path, its SHA-256 and the device hostname.

## `checklist diff`

| Flag | Meaning |
|---|---|
| `--json` | Print the comparison as JSON instead of text |
| `--exit-code` | Exit `2` when there are regressions, other status changes or inventory changes |

Checks are matched by key. `pass -> fail` is a regression, `fail -> pass` is a fix, and anything
involving `error` or a check that exists in only one report is listed under other changes.
Collector output is compared as a set of lines.

## `checklist serve`

| Flag | Default | Meaning |
|---|---|---|
| `--listen` | `127.0.0.1:8080` | Address to listen on. Anything other than loopback requires a token. |
| `--data` | `secbaseline-data` | Directory where reports are stored, as `<platform>_<host>/<timestamp>-<hash>.json`. |
| `--token` | `$CHECKLIST_SERVER_TOKEN` | Shared secret: `Authorization: Bearer <token>` for the API, HTTP Basic (any user, token as password) for browsers. |

| Endpoint | Purpose |
|---|---|
| `POST /api/reports` | Store a report (the JSON written by `checklist run`, up to 32 MiB). Returns `201` with its URL. |
| `GET /api/subjects` | Latest summary, score change and regression count for every host and device, as JSON. |
| `GET /` | Overview, worst first. |
| `GET /s/<subject>` | One host or device: score trend, changes since the previous report, history. |
| `GET /s/<subject>/<file>` | A stored report rendered as HTML. |
| `GET /healthz` | Liveness check (no authentication). |

## Inventory collectors

Collectors are compiled into the binary and print sorted, deterministic text so successive runs can
be diffed against a baseline. Each collector has one ID per platform (see `collector/collector.go`):

| Collector | Linux source | Windows source |
|---|---|---|
| SSH keys | `/root/.ssh/authorized_keys`, `/home/*/.ssh/authorized_keys` | `administrators_authorized_keys`, `C:\Users\*\.ssh\authorized_keys` |
| Accounts | `/etc/passwd` | `Get-LocalUser` |
| Users and groups | `/etc/passwd`, `/etc/group`, `/etc/sudoers` | `net localgroup` and each group's members |
| Password policy | `/etc/login.defs`, PAM | `net accounts` |
| Patching | `uname -a` | most recent hotfix from `Get-HotFix` |
| File checksums | SHA-256 of `--files` | same |
| File listing | files in `--folders` | same |
| Listening ports | non-loopback listeners | same |
| Firewall rules | `sudo iptables`/`ip6tables` for every table | `netsh advfirewall firewall show rule name=all` |
| Log config | rsyslog configuration and service status | SIEM and antivirus agent service status |

The firewall collector calls `sudo`; run the binary as root so it does not wait for a password.

## Package layout

| Package | Role |
|---|---|
| `main.go` | Cobra commands and flags |
| `catalog/` | Loads `controls.yaml`; script paths; per-platform selection |
| `runner/` | Executes scripts, parses verdicts, detects the platform, defines the JSON report |
| `report/` | HTML rendering (`template.html` is embedded into the binary) |
| `drift/` | Report comparison used by `diff` and the dashboard |
| `server/` | Dashboard: file-based report store, HTTP handlers, embedded `dashboard.html` |
| `lint/` | Catalog and script-contract validation |
| `docs/` | README table generation |
| `collector/` | Maps collector IDs to the inventory packages |
| `account/`, `usergroup/`, `ssh/`, `passwordpolicy/`, `patching/`, `filechecksum/`, `file/`, `port/`, `firewall/`, `logconfig/` | One package per collector. OS-specific code lives in `*_linux.go`, `*_windows.go` and `*_darwin.go` (darwin files are stubs). |

## Tests

```bash
cd checklist
go test ./...
go vet ./...
for os in linux windows darwin; do GOOS=$os go build -o /dev/null . || echo "build failed: $os"; done
```

`lint` and `catalog` tests load the real `controls.yaml` and scripts, so `go test ./...` fails if
the repository drifts from its conventions.

## Author & License

Developed and maintained by **Cao Thanh Lam** ([@Khanh1916](https://github.com/Khanh1916)).  
Licensed under the [MIT License](../LICENSE).

