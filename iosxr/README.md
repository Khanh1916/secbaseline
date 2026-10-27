# Cisco IOS XR checks

Offline configuration audit for Cisco IOS XR, IDs `9001–9015`. The checks never connect to a device:
each one reads a saved configuration file (`show running-config`) and prints exactly `PASS` or `FAIL`,
exiting `0` or `1` to match.

Control `9006` is intentionally absent, as on every network platform.

## Usage

Audit a configuration and write an HTML report (from the repository root):

```bash
./checklist/checklist run --platform iosxr --config running-config.txt --html iosxr-audit.html
```

Run one check, or every check with the bundled shell runner:

```bash
bash iosxr/9001.sh running-config.txt
bash iosxr/run_all_scripts.sh running-config.txt
```

Sample configurations for testing: [`asr9k.cfg`](asr9k.cfg).

On Windows, run these from Git Bash, or pass `--shell` with the path to a `bash.exe`.

## Site-specific values

Two checks compare the configuration with your organization's policy. The defaults belong to the
organization that wrote them; set these environment variables before auditing your own devices:

| Variable | Check | Matches | Default |
|---|---|---|---|
| `CHECKLIST_TZ_NAME` | `9009.sh` | `clock timezone areaname <name>` | `Asia/Saigon` |
| `CHECKLIST_SIEM_SERVERS` | `9013.sh` | at least one configured syslog server; `ip` or `ip:port`, space- or comma-separated, port defaults to 514 | `192.168.1.100:514`, `192.168.100.104:514` |

```bash
CHECKLIST_SIEM_SERVERS="10.0.0.5:514 10.0.0.6" CHECKLIST_TZ_NAME=America/New_York \
  ./checklist/checklist run --platform iosxr --config running-config.txt
```

<!-- BEGIN GENERATED: checklist docs -->

### Controls (14)

| ID | Control | Key |
|---:|---|---|
| [9001](9001.sh) | Ensure a non-default hostname is configured | `network.hostname` |
| [9002](9002.sh) | Ensure a login banner is configured | `network.login_banner` |
| [9003](9003.sh) | Ensure an idle session (exec) timeout is configured | `network.exec_timeout` |
| [9004](9004.sh) | Ensure management access is restricted to permitted addresses | `network.mgmt_access_acl` |
| [9005](9005.sh) | Ensure unused services and protocols are disabled | `network.unused_services_disabled` |
| [9007](9007.sh) | Ensure console and auxiliary lines require authentication | `network.console_auth` |
| [9008](9008.sh) | Ensure centralized AAA authentication (TACACS+/RADIUS) is configured | `network.aaa_central_auth` |
| [9009](9009.sh) | Ensure time zone and NTP synchronization are configured | `network.ntp_timezone` |
| [9010](9010.sh) | Ensure SNMP is secured | `network.snmp_secured` |
| [9011](9011.sh) | Ensure SSH version 2 is used for remote access | `network.ssh_remote_access` |
| [9012](9012.sh) | Ensure strong password encryption and policy are configured | `network.password_encryption` |
| [9013](9013.sh) | Ensure logs are sent to central syslog/SIEM servers | `network.central_logging` |
| [9014](9014.sh) | Ensure failed login attempts are limited | `network.login_attempts_limited` |
| [9015](9015.sh) | Ensure automatic configuration backup is configured | `network.config_backup` |

<!-- END GENERATED -->
