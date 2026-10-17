# Cisco IOS XE checks

Offline configuration audit for Cisco IOS XE, IDs `7001–7015`. The checks never connect to a device:
each one reads a saved configuration file (`show running-config`) and prints exactly `PASS` or `FAIL`,
exiting `0` or `1` to match.

Control `7006` is intentionally absent, as on every network platform.

## Usage

Audit a configuration and write an HTML report (from the repository root):

```bash
./checklist/checklist run --platform iosxe --config running-config.txt --html iosxe-audit.html
```

Run one check, or every check with the bundled shell runner:

```bash
bash iosxe/7001.sh running-config.txt
bash iosxe/iosxe_run_all.sh running-config.txt
```

Sample configurations for testing: [`iosxe.cfg`](iosxe.cfg), [`cat8k.cfg`](cat8k.cfg).

On Windows, run these from Git Bash, or pass `--shell` with the path to a `bash.exe`.

## Site-specific values

Some checks encode one organization's policy. Review them before auditing your own devices:

- Time zone: `7009.sh` expects `clock timezone <name> 7` (UTC+7).
- Central logging: `7013.sh` accepts only the servers in its `SIEM_SERVERS` array.

<!-- BEGIN GENERATED: checklist docs -->

### Controls (14)

| ID | Control | Key |
|---:|---|---|
| [7001](7001.sh) | Ensure a non-default hostname is configured | `network.hostname` |
| [7002](7002.sh) | Ensure a login banner is configured | `network.login_banner` |
| [7003](7003.sh) | Ensure an idle session (exec) timeout is configured | `network.exec_timeout` |
| [7004](7004.sh) | Ensure management access is restricted to permitted addresses | `network.mgmt_access_acl` |
| [7005](7005.sh) | Ensure unused services and protocols are disabled | `network.unused_services_disabled` |
| [7007](7007.sh) | Ensure console and auxiliary lines require authentication | `network.console_auth` |
| [7008](7008.sh) | Ensure centralized AAA authentication (TACACS+/RADIUS) is configured | `network.aaa_central_auth` |
| [7009](7009.sh) | Ensure time zone and NTP synchronization are configured | `network.ntp_timezone` |
| [7010](7010.sh) | Ensure SNMP is secured | `network.snmp_secured` |
| [7011](7011.sh) | Ensure SSH version 2 is used for remote access | `network.ssh_remote_access` |
| [7012](7012.sh) | Ensure strong password encryption and policy are configured | `network.password_encryption` |
| [7013](7013.sh) | Ensure logs are sent to central syslog/SIEM servers | `network.central_logging` |
| [7014](7014.sh) | Ensure failed login attempts are limited | `network.login_attempts_limited` |
| [7015](7015.sh) | Ensure automatic configuration backup is configured | `network.config_backup` |

<!-- END GENERATED -->
