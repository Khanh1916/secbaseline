# Ubuntu checks

CIS-style hardening checks for Ubuntu, IDs `1001–1090`. Inventory collectors `1091–1100` are served by the Go binary (`checklist <id>`), not by scripts here.

Each script runs on the target host with no arguments, prints optional `INFO:` detail
lines followed by exactly one `PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or
`1` (fail). Most checks read root-only files, so run them as root.

## Usage

Run every check and write a report (from the repository root):

```bash
sudo ./checklist/checklist run --platform ubuntu --html ubuntu-report.html -o ubuntu-report.json
```

`--platform` can be omitted on the host itself; the runner detects the distribution from `/etc/os-release`.

Run one check:

```bash
sudo bash ubuntu/1001.sh; echo "exit=$?"
```

## Notes

- Package checks use `dpkg -s`; service checks use `systemctl`.
- Control order matches the RHEL family up to `1049`. Ubuntu has no separate NIS client control (RHEL index 50), so from `1050` (rsh) onward Ubuntu IDs are one lower than the RHEL index. `controls.yaml` holds the exact mapping.
- Debian uses the same scripts with an `11` prefix (see [`../debian`](../debian)).

<!-- BEGIN GENERATED: checklist docs -->

### Controls (90)

| ID | Control | Key |
|---:|---|---|
| [1001](1001.sh) | Ensure the cramfs kernel module is disabled | `linux.filesystem.cramfs_disabled` |
| [1002](1002.sh) | Ensure the squashfs kernel module is disabled | `linux.filesystem.squashfs_disabled` |
| [1003](1003.sh) | Ensure the udf kernel module is disabled | `linux.filesystem.udf_disabled` |
| [1004](1004.sh) | Ensure /tmp is a separate partition | `linux.filesystem.tmp_partition` |
| [1005](1005.sh) | Ensure nodev option is set on /tmp | `linux.filesystem.tmp_nodev` |
| [1006](1006.sh) | Ensure nosuid option is set on /tmp | `linux.filesystem.tmp_nosuid` |
| [1007](1007.sh) | Ensure noexec option is set on /tmp | `linux.filesystem.tmp_noexec` |
| [1008](1008.sh) | Ensure /dev/shm is a separate partition | `linux.filesystem.dev_shm_partition` |
| [1009](1009.sh) | Ensure nodev option is set on /dev/shm | `linux.filesystem.dev_shm_nodev` |
| [1010](1010.sh) | Ensure nosuid option is set on /dev/shm | `linux.filesystem.dev_shm_nosuid` |
| [1011](1011.sh) | Ensure noexec option is set on /dev/shm | `linux.filesystem.dev_shm_noexec` |
| [1012](1012.sh) | Ensure /var is a separate partition | `linux.filesystem.var_partition` |
| [1013](1013.sh) | Ensure /var/tmp is a separate partition or bound to /tmp | `linux.filesystem.var_tmp_partition` |
| [1014](1014.sh) | Ensure /var/log is a separate partition | `linux.filesystem.var_log_partition` |
| [1015](1015.sh) | Ensure /var/log/audit is a separate partition | `linux.filesystem.var_log_audit_partition` |
| [1016](1016.sh) | Ensure /home is a separate partition | `linux.filesystem.home_partition` |
| [1017](1017.sh) | Ensure nodev option is set on /home | `linux.filesystem.home_nodev` |
| [1018](1018.sh) | Ensure sticky bit is set on all world-writable directories | `linux.filesystem.sticky_bit` |
| [1019](1019.sh) | Ensure AIDE is installed | `linux.integrity.aide_installed` |
| [1020](1020.sh) | Ensure core dumps are restricted | `linux.hardening.core_dumps_restricted` |
| [1021](1021.sh) | Ensure address space layout randomization (ASLR) is enabled | `linux.hardening.aslr_enabled` |
| [1022](1022.sh) | Ensure prelink is not installed | `linux.hardening.prelink_removed` |
| [1023](1023.sh) | Ensure SELinux is installed | `linux.mac.selinux_installed` |
| [1024](1024.sh) | Ensure SELinux is not disabled | `linux.mac.selinux_not_disabled` |
| [1025](1025.sh) | Ensure SELinux mode is enforcing or permissive | `linux.mac.selinux_mode` |
| [1026](1026.sh) | Ensure SELinux mode is enforcing | `linux.mac.selinux_enforcing` |
| [1027](1027.sh) | Ensure SETroubleshoot is not installed | `linux.mac.setroubleshoot_removed` |
| [1028](1028.sh) | Ensure the MCS Translation Service (mcstrans) is not installed | `linux.mac.mcstrans_removed` |
| [1029](1029.sh) | Ensure a login warning banner is configured | `linux.banner.login_banner` |
| [1030](1030.sh) | Ensure the login banner does not disclose OS information | `linux.banner.banner_no_os_info` |
| [1031](1031.sh) | Ensure the system clock is synchronized | `linux.time.clock_synchronized` |
| [1032](1032.sh) | Ensure chrony is enabled | `linux.time.chrony_enabled` |
| [1033](1033.sh) | Ensure ntp is enabled | `linux.time.ntp_enabled` |
| [1034](1034.sh) | Ensure xinetd is not installed | `linux.services.xinetd_removed` |
| [1035](1035.sh) | Ensure the X Window System is not installed | `linux.services.xorg_removed` |
| [1036](1036.sh) | Ensure the Avahi server is not enabled | `linux.services.avahi_disabled` |
| [1037](1037.sh) | Ensure CUPS is not enabled | `linux.services.cups_disabled` |
| [1038](1038.sh) | Ensure a DHCP server is not installed | `linux.services.dhcp_server_removed` |
| [1039](1039.sh) | Ensure an LDAP server is not installed | `linux.services.ldap_server_removed` |
| [1040](1040.sh) | Ensure a DNS server is not installed | `linux.services.dns_server_removed` |
| [1041](1041.sh) | Ensure an FTP server is not installed | `linux.services.ftp_server_removed` |
| [1042](1042.sh) | Ensure an HTTP server is not installed | `linux.services.http_server_removed` |
| [1043](1043.sh) | Ensure an IMAP/POP3 server is not installed | `linux.services.imap_pop3_removed` |
| [1044](1044.sh) | Ensure Samba is not installed | `linux.services.samba_removed` |
| [1045](1045.sh) | Ensure an HTTP proxy server is not installed | `linux.services.http_proxy_removed` |
| [1046](1046.sh) | Ensure the NIS server is not installed | `linux.services.nis_server_removed` |
| [1047](1047.sh) | Ensure the telnet server is not installed | `linux.services.telnet_server_removed` |
| [1048](1048.sh) | Ensure the mail transfer agent is configured for local-only mode | `linux.services.mta_local_only` |
| [1049](1049.sh) | Ensure the NFS server is not enabled | `linux.services.nfs_disabled` |
| [1050](1050.sh) | Ensure the rsh client is not installed | `linux.clients.rsh_removed` |
| [1051](1051.sh) | Ensure the talk client is not installed | `linux.clients.talk_removed` |
| [1052](1052.sh) | Ensure the LDAP client is not installed | `linux.clients.ldap_client_removed` |
| [1053](1053.sh) | Ensure IP forwarding is disabled | `linux.network.ip_forward_disabled` |
| [1054](1054.sh) | Ensure packet redirect sending is disabled | `linux.network.send_redirects_disabled` |
| [1055](1055.sh) | Ensure source routed packets are not accepted | `linux.network.source_route_rejected` |
| [1056](1056.sh) | Ensure ICMP redirects are not accepted | `linux.network.icmp_redirects_rejected` |
| [1057](1057.sh) | Ensure secure ICMP redirects are not accepted | `linux.network.secure_redirects_rejected` |
| [1058](1058.sh) | Ensure suspicious (martian) packets are logged | `linux.network.log_martians` |
| [1059](1059.sh) | Ensure broadcast ICMP requests are ignored | `linux.network.ignore_broadcast_icmp` |
| [1060](1060.sh) | Ensure bogus ICMP responses are ignored | `linux.network.ignore_bogus_icmp` |
| [1061](1061.sh) | Ensure reverse path filtering is enabled | `linux.network.rp_filter` |
| [1062](1062.sh) | Ensure TCP SYN cookies are enabled | `linux.network.tcp_syncookies` |
| [1063](1063.sh) | Ensure TCP Wrappers is installed | `linux.tcp_wrappers.tcp_wrappers_installed` |
| [1064](1064.sh) | Ensure /etc/hosts.allow is configured | `linux.tcp_wrappers.hosts_allow_configured` |
| [1065](1065.sh) | Ensure permissions on /etc/hosts.allow are configured | `linux.tcp_wrappers.hosts_allow_perms` |
| [1066](1066.sh) | Ensure /etc/hosts.deny denies all by default | `linux.tcp_wrappers.hosts_deny_configured` |
| [1067](1067.sh) | Ensure permissions on /etc/hosts.deny are configured | `linux.tcp_wrappers.hosts_deny_perms` |
| [1068](1068.sh) | Ensure a host firewall is enabled | `linux.firewall.firewall_enabled` |
| [1069](1069.sh) | Ensure firewall rules are configured | `linux.firewall.firewall_rules` |
| [1070](1070.sh) | Ensure permissions on /etc/ssh/sshd_config are configured | `linux.ssh.sshd_config_perms` |
| [1071](1071.sh) | Ensure SSH Protocol is set to 2 | `linux.ssh.ssh_protocol_2` |
| [1072](1072.sh) | Ensure SSH LogLevel is INFO or VERBOSE | `linux.ssh.ssh_loglevel` |
| [1073](1073.sh) | Ensure SSH X11 forwarding is disabled | `linux.ssh.ssh_x11_forwarding_disabled` |
| [1074](1074.sh) | Ensure SSH MaxAuthTries is set to 4 or less | `linux.ssh.ssh_max_auth_tries` |
| [1075](1075.sh) | Ensure SSH root login is disabled | `linux.ssh.ssh_root_login_disabled` |
| [1076](1076.sh) | Ensure rsyslog is installed and enabled | `linux.logging.rsyslog_enabled` |
| [1077](1077.sh) | Ensure permissions on log files are configured | `linux.logging.log_file_perms` |
| [1078](1078.sh) | Ensure audit rules are configured | `linux.audit.audit_rules` |
| [1079](1079.sh) | Ensure auditd is installed | `linux.audit.auditd_installed` |
| [1080](1080.sh) | Ensure the auditd service is enabled and running | `linux.audit.auditd_enabled` |
| [1081](1081.sh) | Ensure an account lockout PAM module is configured | `linux.auth.lockout_module` |
| [1082](1082.sh) | Ensure password quality requirements are configured | `linux.auth.pwquality` |
| [1083](1083.sh) | Ensure lockout after failed password attempts is configured | `linux.auth.lockout_deny` |
| [1084](1084.sh) | Ensure password reuse is limited | `linux.auth.password_reuse` |
| [1085](1085.sh) | Ensure the password hashing algorithm is SHA-512 or yescrypt | `linux.auth.password_hash_sha512` |
| [1086](1086.sh) | Ensure password expiration is 90 days or less | `linux.auth.pass_max_days` |
| [1087](1087.sh) | Ensure user password expiration is set | `linux.auth.password_expiry_set` |
| [1088](1088.sh) | Ensure minimum days between password changes is 1 or more | `linux.auth.pass_min_days` |
| [1089](1089.sh) | Ensure password expiration warning is 7 days or more | `linux.auth.pass_warn_age` |
| [1090](1090.sh) | Ensure the inactive password lock (INACTIVE) is configured | `linux.auth.inactive_lock` |

### Inventory collectors (10)

Served by the Go binary: `checklist <id>`.

| ID | Collects | Key |
|---:|---|---|
| 1091 | SSH authorized_keys per user | `collect.ssh_keys` |
| 1092 | Local account names | `collect.accounts` |
| 1093 | Users, groups and sudoers/administrators membership | `collect.users_groups` |
| 1094 | Effective password policy | `collect.password_policy` |
| 1095 | OS, kernel and patch level | `collect.patching` |
| 1096 | SHA-256 checksums of the files given with --files | `collect.file_checksums` |
| 1097 | Files in the directories given with --folders | `collect.file_listing` |
| 1098 | Non-loopback listening TCP/UDP ports | `collect.listening_ports` |
| 1099 | Host firewall rules | `collect.firewall_rules` |
| 1100 | Logging configuration and agent status | `collect.log_config` |

<!-- END GENERATED -->
