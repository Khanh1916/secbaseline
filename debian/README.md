# Debian checks

CIS-style hardening checks for Debian, IDs `11001–11090`. Inventory collectors `11091–11100` are served by the Go binary (`checklist <id>`), not by scripts here.

Each script runs on the target host with no arguments, prints optional `INFO:` detail
lines followed by exactly one `PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or
`1` (fail). Most checks read root-only files, so run them as root.

## Usage

Run every check and write a report (from the repository root):

```bash
sudo ./checklist/checklist run --platform debian --html debian-report.html -o debian-report.json
```

`--platform` can be omitted on the host itself; the runner detects the distribution from `/etc/os-release`.

Run one check:

```bash
sudo bash debian/11001.sh; echo "exit=$?"
```

## Notes

- These scripts were copied from [`../ubuntu`](../ubuntu) and renamed with [`rename.sh`](rename.sh) (`1001.sh` → `11001.sh`). A fix to one usually belongs in both.
- The only intentional difference is `11083.sh`, which checks both `pam_faillock` and `pam_tally2`.

<!-- BEGIN GENERATED: checklist docs -->

### Controls (90)

| ID | Control | Key |
|---:|---|---|
| [11001](11001.sh) | Ensure the cramfs kernel module is disabled | `linux.filesystem.cramfs_disabled` |
| [11002](11002.sh) | Ensure the squashfs kernel module is disabled | `linux.filesystem.squashfs_disabled` |
| [11003](11003.sh) | Ensure the udf kernel module is disabled | `linux.filesystem.udf_disabled` |
| [11004](11004.sh) | Ensure /tmp is a separate partition | `linux.filesystem.tmp_partition` |
| [11005](11005.sh) | Ensure nodev option is set on /tmp | `linux.filesystem.tmp_nodev` |
| [11006](11006.sh) | Ensure nosuid option is set on /tmp | `linux.filesystem.tmp_nosuid` |
| [11007](11007.sh) | Ensure noexec option is set on /tmp | `linux.filesystem.tmp_noexec` |
| [11008](11008.sh) | Ensure /dev/shm is a separate partition | `linux.filesystem.dev_shm_partition` |
| [11009](11009.sh) | Ensure nodev option is set on /dev/shm | `linux.filesystem.dev_shm_nodev` |
| [11010](11010.sh) | Ensure nosuid option is set on /dev/shm | `linux.filesystem.dev_shm_nosuid` |
| [11011](11011.sh) | Ensure noexec option is set on /dev/shm | `linux.filesystem.dev_shm_noexec` |
| [11012](11012.sh) | Ensure /var is a separate partition | `linux.filesystem.var_partition` |
| [11013](11013.sh) | Ensure /var/tmp is a separate partition or bound to /tmp | `linux.filesystem.var_tmp_partition` |
| [11014](11014.sh) | Ensure /var/log is a separate partition | `linux.filesystem.var_log_partition` |
| [11015](11015.sh) | Ensure /var/log/audit is a separate partition | `linux.filesystem.var_log_audit_partition` |
| [11016](11016.sh) | Ensure /home is a separate partition | `linux.filesystem.home_partition` |
| [11017](11017.sh) | Ensure nodev option is set on /home | `linux.filesystem.home_nodev` |
| [11018](11018.sh) | Ensure sticky bit is set on all world-writable directories | `linux.filesystem.sticky_bit` |
| [11019](11019.sh) | Ensure AIDE is installed | `linux.integrity.aide_installed` |
| [11020](11020.sh) | Ensure core dumps are restricted | `linux.hardening.core_dumps_restricted` |
| [11021](11021.sh) | Ensure address space layout randomization (ASLR) is enabled | `linux.hardening.aslr_enabled` |
| [11022](11022.sh) | Ensure prelink is not installed | `linux.hardening.prelink_removed` |
| [11023](11023.sh) | Ensure SELinux is installed | `linux.mac.selinux_installed` |
| [11024](11024.sh) | Ensure SELinux is not disabled | `linux.mac.selinux_not_disabled` |
| [11025](11025.sh) | Ensure SELinux mode is enforcing or permissive | `linux.mac.selinux_mode` |
| [11026](11026.sh) | Ensure SELinux mode is enforcing | `linux.mac.selinux_enforcing` |
| [11027](11027.sh) | Ensure SETroubleshoot is not installed | `linux.mac.setroubleshoot_removed` |
| [11028](11028.sh) | Ensure the MCS Translation Service (mcstrans) is not installed | `linux.mac.mcstrans_removed` |
| [11029](11029.sh) | Ensure a login warning banner is configured | `linux.banner.login_banner` |
| [11030](11030.sh) | Ensure the login banner does not disclose OS information | `linux.banner.banner_no_os_info` |
| [11031](11031.sh) | Ensure the system clock is synchronized | `linux.time.clock_synchronized` |
| [11032](11032.sh) | Ensure chrony is enabled | `linux.time.chrony_enabled` |
| [11033](11033.sh) | Ensure ntp is enabled | `linux.time.ntp_enabled` |
| [11034](11034.sh) | Ensure xinetd is not installed | `linux.services.xinetd_removed` |
| [11035](11035.sh) | Ensure the X Window System is not installed | `linux.services.xorg_removed` |
| [11036](11036.sh) | Ensure the Avahi server is not enabled | `linux.services.avahi_disabled` |
| [11037](11037.sh) | Ensure CUPS is not enabled | `linux.services.cups_disabled` |
| [11038](11038.sh) | Ensure a DHCP server is not installed | `linux.services.dhcp_server_removed` |
| [11039](11039.sh) | Ensure an LDAP server is not installed | `linux.services.ldap_server_removed` |
| [11040](11040.sh) | Ensure a DNS server is not installed | `linux.services.dns_server_removed` |
| [11041](11041.sh) | Ensure an FTP server is not installed | `linux.services.ftp_server_removed` |
| [11042](11042.sh) | Ensure an HTTP server is not installed | `linux.services.http_server_removed` |
| [11043](11043.sh) | Ensure an IMAP/POP3 server is not installed | `linux.services.imap_pop3_removed` |
| [11044](11044.sh) | Ensure Samba is not installed | `linux.services.samba_removed` |
| [11045](11045.sh) | Ensure an HTTP proxy server is not installed | `linux.services.http_proxy_removed` |
| [11046](11046.sh) | Ensure the NIS server is not installed | `linux.services.nis_server_removed` |
| [11047](11047.sh) | Ensure the telnet server is not installed | `linux.services.telnet_server_removed` |
| [11048](11048.sh) | Ensure the mail transfer agent is configured for local-only mode | `linux.services.mta_local_only` |
| [11049](11049.sh) | Ensure the NFS server is not enabled | `linux.services.nfs_disabled` |
| [11050](11050.sh) | Ensure the rsh client is not installed | `linux.clients.rsh_removed` |
| [11051](11051.sh) | Ensure the talk client is not installed | `linux.clients.talk_removed` |
| [11052](11052.sh) | Ensure the LDAP client is not installed | `linux.clients.ldap_client_removed` |
| [11053](11053.sh) | Ensure IP forwarding is disabled | `linux.network.ip_forward_disabled` |
| [11054](11054.sh) | Ensure packet redirect sending is disabled | `linux.network.send_redirects_disabled` |
| [11055](11055.sh) | Ensure source routed packets are not accepted | `linux.network.source_route_rejected` |
| [11056](11056.sh) | Ensure ICMP redirects are not accepted | `linux.network.icmp_redirects_rejected` |
| [11057](11057.sh) | Ensure secure ICMP redirects are not accepted | `linux.network.secure_redirects_rejected` |
| [11058](11058.sh) | Ensure suspicious (martian) packets are logged | `linux.network.log_martians` |
| [11059](11059.sh) | Ensure broadcast ICMP requests are ignored | `linux.network.ignore_broadcast_icmp` |
| [11060](11060.sh) | Ensure bogus ICMP responses are ignored | `linux.network.ignore_bogus_icmp` |
| [11061](11061.sh) | Ensure reverse path filtering is enabled | `linux.network.rp_filter` |
| [11062](11062.sh) | Ensure TCP SYN cookies are enabled | `linux.network.tcp_syncookies` |
| [11063](11063.sh) | Ensure TCP Wrappers is installed | `linux.tcp_wrappers.tcp_wrappers_installed` |
| [11064](11064.sh) | Ensure /etc/hosts.allow is configured | `linux.tcp_wrappers.hosts_allow_configured` |
| [11065](11065.sh) | Ensure permissions on /etc/hosts.allow are configured | `linux.tcp_wrappers.hosts_allow_perms` |
| [11066](11066.sh) | Ensure /etc/hosts.deny denies all by default | `linux.tcp_wrappers.hosts_deny_configured` |
| [11067](11067.sh) | Ensure permissions on /etc/hosts.deny are configured | `linux.tcp_wrappers.hosts_deny_perms` |
| [11068](11068.sh) | Ensure a host firewall is enabled | `linux.firewall.firewall_enabled` |
| [11069](11069.sh) | Ensure firewall rules are configured | `linux.firewall.firewall_rules` |
| [11070](11070.sh) | Ensure permissions on /etc/ssh/sshd_config are configured | `linux.ssh.sshd_config_perms` |
| [11071](11071.sh) | Ensure SSH Protocol is set to 2 | `linux.ssh.ssh_protocol_2` |
| [11072](11072.sh) | Ensure SSH LogLevel is INFO or VERBOSE | `linux.ssh.ssh_loglevel` |
| [11073](11073.sh) | Ensure SSH X11 forwarding is disabled | `linux.ssh.ssh_x11_forwarding_disabled` |
| [11074](11074.sh) | Ensure SSH MaxAuthTries is set to 4 or less | `linux.ssh.ssh_max_auth_tries` |
| [11075](11075.sh) | Ensure SSH root login is disabled | `linux.ssh.ssh_root_login_disabled` |
| [11076](11076.sh) | Ensure rsyslog is installed and enabled | `linux.logging.rsyslog_enabled` |
| [11077](11077.sh) | Ensure permissions on log files are configured | `linux.logging.log_file_perms` |
| [11078](11078.sh) | Ensure audit rules are configured | `linux.audit.audit_rules` |
| [11079](11079.sh) | Ensure auditd is installed | `linux.audit.auditd_installed` |
| [11080](11080.sh) | Ensure the auditd service is enabled and running | `linux.audit.auditd_enabled` |
| [11081](11081.sh) | Ensure an account lockout PAM module is configured | `linux.auth.lockout_module` |
| [11082](11082.sh) | Ensure password quality requirements are configured | `linux.auth.pwquality` |
| [11083](11083.sh) | Ensure lockout after failed password attempts is configured | `linux.auth.lockout_deny` |
| [11084](11084.sh) | Ensure password reuse is limited | `linux.auth.password_reuse` |
| [11085](11085.sh) | Ensure the password hashing algorithm is SHA-512 | `linux.auth.password_hash_sha512` |
| [11086](11086.sh) | Ensure password expiration is 90 days or less | `linux.auth.pass_max_days` |
| [11087](11087.sh) | Ensure user password expiration is set | `linux.auth.password_expiry_set` |
| [11088](11088.sh) | Ensure minimum days between password changes is 1 or more | `linux.auth.pass_min_days` |
| [11089](11089.sh) | Ensure password expiration warning is 7 days or more | `linux.auth.pass_warn_age` |
| [11090](11090.sh) | Ensure the inactive password lock (INACTIVE) is configured | `linux.auth.inactive_lock` |

### Inventory collectors (10)

Served by the Go binary: `checklist <id>`.

| ID | Collects | Key |
|---:|---|---|
| 11091 | SSH authorized_keys per user | `collect.ssh_keys` |
| 11092 | Local account names | `collect.accounts` |
| 11093 | Users, groups and sudoers/administrators membership | `collect.users_groups` |
| 11094 | Effective password policy | `collect.password_policy` |
| 11095 | OS, kernel and patch level | `collect.patching` |
| 11096 | SHA-256 checksums of the files given with --files | `collect.file_checksums` |
| 11097 | Files in the directories given with --folders | `collect.file_listing` |
| 11098 | Non-loopback listening TCP/UDP ports | `collect.listening_ports` |
| 11099 | Host firewall rules | `collect.firewall_rules` |
| 11100 | Logging configuration and agent status | `collect.log_config` |

<!-- END GENERATED -->
