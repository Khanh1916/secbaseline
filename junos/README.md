# Juniper Junos checks

Offline configuration audit for Juniper Junos, IDs `8001–8015`. The checks never connect to a device:
each one reads a saved configuration file (`show configuration | display set`) and prints exactly `PASS` or `FAIL`,
exiting `0` or `1` to match.

Control `8006` is intentionally absent, as on every network platform.

## Usage

Audit a configuration and write an HTML report (from the repository root):

```bash
./checklist/checklist run --platform junos --config running-config.txt --html junos-audit.html
```

Run one check, or every check with the bundled shell runner:

```bash
bash junos/8001.sh running-config.txt
bash junos/junos_run_all.sh running-config.txt
```

Sample configurations for testing: [`jsw.cfg`](jsw.cfg).

On Windows, run these from Git Bash, or pass `--shell` with the path to a `bash.exe`.

## Site-specific values

Two checks compare the configuration with your organization's policy. The defaults belong to the
organization that wrote them; set these environment variables before auditing your own devices:

| Variable | Check | Matches | Default |
|---|---|---|---|
| `CHECKLIST_TZ_NAME` | `8009.sh` | `set system time-zone <name>` | `Asia/Saigon` |
| `CHECKLIST_SIEM_SERVERS` | `8013.sh` | at least one configured syslog server; `ip` or `ip:port`, space- or comma-separated, port defaults to 514 | `192.168.1.100:514`, `192.168.100.104:514` |

```bash
CHECKLIST_SIEM_SERVERS="10.0.0.5:514 10.0.0.6" CHECKLIST_TZ_NAME=America/New_York   ./checklist/checklist run --platform junos --config running-config.txt
```

<!-- BEGIN GENERATED: checklist docs -->

### Controls (14)

| ID | Control | Key |
|---:|---|---|
| [8001](8001.sh) | Ensure a non-default hostname is configured | `network.hostname` |
| [8002](8002.sh) | Ensure a login banner is configured | `network.login_banner` |
| [8003](8003.sh) | Ensure an idle session (exec) timeout is configured | `network.exec_timeout` |
| [8004](8004.sh) | Ensure management access is restricted to permitted addresses | `network.mgmt_access_acl` |
| [8005](8005.sh) | Ensure unused services and protocols are disabled | `network.unused_services_disabled` |
| [8007](8007.sh) | Ensure console and auxiliary lines require authentication | `network.console_auth` |
| [8008](8008.sh) | Ensure centralized AAA authentication (TACACS+/RADIUS) is configured | `network.aaa_central_auth` |
| [8009](8009.sh) | Ensure time zone and NTP synchronization are configured | `network.ntp_timezone` |
| [8010](8010.sh) | Ensure SNMP is secured | `network.snmp_secured` |
| [8011](8011.sh) | Ensure SSH version 2 is used for remote access | `network.ssh_remote_access` |
| [8012](8012.sh) | Ensure strong password encryption and policy are configured | `network.password_encryption` |
| [8013](8013.sh) | Ensure logs are sent to central syslog/SIEM servers | `network.central_logging` |
| [8014](8014.sh) | Ensure failed login attempts are limited | `network.login_attempts_limited` |
| [8015](8015.sh) | Ensure automatic configuration backup is configured | `network.config_backup` |

<!-- END GENERATED -->
