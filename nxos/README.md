# Cisco NX-OS checks

Offline configuration audit for Cisco NX-OS, IDs `10001–10015`. The checks never connect to a device:
each one reads a saved configuration file (`show running-config`) and prints exactly `PASS` or `FAIL`,
exiting `0` or `1` to match.

Control `10006` is intentionally absent, as on every network platform.

## Usage

Audit a configuration and write an HTML report (from the repository root):

```bash
./checklist/checklist run --platform nxos --config running-config.txt --html nxos-audit.html
```

Run one check, or every check with the bundled shell runner:

```bash
bash nxos/10001.sh running-config.txt
bash nxos/nxos_run_all.sh running-config.txt
```

Sample configurations for testing: [`n9k.cfg`](n9k.cfg).

On Windows, run these from Git Bash, or pass `--shell` with the path to a `bash.exe`.

## Site-specific values

Two checks compare the configuration with your organization's policy. The defaults belong to the
organization that wrote them; set these environment variables before auditing your own devices:

| Variable | Check | Matches | Default |
|---|---|---|---|
| `CHECKLIST_TZ_OFFSET` | `10009.sh` | `clock timezone <name> <offset> 0` | `7` |
| `CHECKLIST_SIEM_SERVERS` | `10013.sh` | at least one configured syslog server; `ip` or `ip:port`, space- or comma-separated, port defaults to 514 | `192.168.89.104:1514`, `192.168.89.104:514`, `192.168.89.105:1514`, `10.1.1.100:514`, `172.16.10.50:514` |

```bash
CHECKLIST_SIEM_SERVERS="10.0.0.5:514 10.0.0.6" CHECKLIST_TZ_OFFSET=-5 \
  ./checklist/checklist run --platform nxos --config running-config.txt
```

<!-- BEGIN GENERATED: checklist docs -->

### Controls (14)

| ID | Control | Key |
|---:|---|---|
| [10001](10001.sh) | Ensure a non-default hostname is configured | `network.hostname` |
| [10002](10002.sh) | Ensure a login banner is configured | `network.login_banner` |
| [10003](10003.sh) | Ensure an idle session (exec) timeout is configured | `network.exec_timeout` |
| [10004](10004.sh) | Ensure management access is restricted to permitted addresses | `network.mgmt_access_acl` |
| [10005](10005.sh) | Ensure unused services and protocols are disabled | `network.unused_services_disabled` |
| [10007](10007.sh) | Ensure console and auxiliary lines require authentication | `network.console_auth` |
| [10008](10008.sh) | Ensure centralized AAA authentication (TACACS+/RADIUS) is configured | `network.aaa_central_auth` |
| [10009](10009.sh) | Ensure time zone and NTP synchronization are configured | `network.ntp_timezone` |
| [10010](10010.sh) | Ensure SNMP is secured | `network.snmp_secured` |
| [10011](10011.sh) | Ensure SSH version 2 is used for remote access | `network.ssh_remote_access` |
| [10012](10012.sh) | Ensure strong password encryption and policy are configured | `network.password_encryption` |
| [10013](10013.sh) | Ensure logs are sent to central syslog/SIEM servers | `network.central_logging` |
| [10014](10014.sh) | Ensure failed login attempts are limited | `network.login_attempts_limited` |
| [10015](10015.sh) | Ensure automatic configuration backup is configured | `network.config_backup` |

<!-- END GENERATED -->
