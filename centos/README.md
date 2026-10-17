# CentOS checks

CIS-style hardening checks for CentOS, IDs `5001–5091`. Inventory collectors `5092–5101` are served by the Go binary (`checklist <id>`), not by scripts here.

Each script runs on the target host with no arguments, prints optional `INFO:` detail
lines followed by exactly one `PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or
`1` (fail). Most checks read root-only files, so run them as root.

## Usage

Run every check and write a report (from the repository root):

```bash
sudo ./checklist/checklist run --platform centos --html centos-report.html -o centos-report.json
```

`--platform` can be omitted on the host itself; the runner detects the distribution from `/etc/os-release`.

Run one check:

```bash
sudo bash centos/5001.sh; echo "exit=$?"
```

## Notes

- Identical to [`../redhat`](../redhat) except `5030.sh`, whose banner check looks for "CentOS".

<!-- BEGIN GENERATED: checklist docs -->

### Controls (91)

| ID | Control | Key |
|---:|---|---|
| [5001](5001.sh) | Ensure the cramfs kernel module is disabled | `linux.filesystem.cramfs_disabled` |
| [5002](5002.sh) | Ensure the squashfs kernel module is disabled | `linux.filesystem.squashfs_disabled` |
| [5003](5003.sh) | Ensure the udf kernel module is disabled | `linux.filesystem.udf_disabled` |
| [5004](5004.sh) | Ensure /tmp is a separate partition | `linux.filesystem.tmp_partition` |
| [5005](5005.sh) | Ensure nodev option is set on /tmp | `linux.filesystem.tmp_nodev` |
| [5006](5006.sh) | Ensure nosuid option is set on /tmp | `linux.filesystem.tmp_nosuid` |
| [5007](5007.sh) | Ensure noexec option is set on /tmp | `linux.filesystem.tmp_noexec` |
| [5008](5008.sh) | Ensure /dev/shm is a separate partition | `linux.filesystem.dev_shm_partition` |
| [5009](5009.sh) | Ensure nodev option is set on /dev/shm | `linux.filesystem.dev_shm_nodev` |
| [5010](5010.sh) | Ensure nosuid option is set on /dev/shm | `linux.filesystem.dev_shm_nosuid` |
| [5011](5011.sh) | Ensure noexec option is set on /dev/shm | `linux.filesystem.dev_shm_noexec` |
| [5012](5012.sh) | Ensure /var is a separate partition | `linux.filesystem.var_partition` |
| [5013](5013.sh) | Ensure /var/tmp is a separate partition or bound to /tmp | `linux.filesystem.var_tmp_partition` |
| [5014](5014.sh) | Ensure /var/log is a separate partition | `linux.filesystem.var_log_partition` |
| [5015](5015.sh) | Ensure /var/log/audit is a separate partition | `linux.filesystem.var_log_audit_partition` |
| [5016](5016.sh) | Ensure /home is a separate partition | `linux.filesystem.home_partition` |
| [5017](5017.sh) | Ensure nodev option is set on /home | `linux.filesystem.home_nodev` |
| [5018](5018.sh) | Ensure sticky bit is set on all world-writable directories | `linux.filesystem.sticky_bit` |
| [5019](5019.sh) | Ensure AIDE is installed | `linux.integrity.aide_installed` |
| [5020](5020.sh) | Ensure core dumps are restricted | `linux.hardening.core_dumps_restricted` |
| [5021](5021.sh) | Ensure address space layout randomization (ASLR) is enabled | `linux.hardening.aslr_enabled` |
| [5022](5022.sh) | Ensure prelink is not installed | `linux.hardening.prelink_removed` |
| [5023](5023.sh) | Ensure SELinux is installed | `linux.mac.selinux_installed` |
| [5024](5024.sh) | Ensure SELinux is not disabled | `linux.mac.selinux_not_disabled` |
| [5025](5025.sh) | Ensure SELinux mode is enforcing or permissive | `linux.mac.selinux_mode` |
| [5026](5026.sh) | Ensure SELinux mode is enforcing | `linux.mac.selinux_enforcing` |
| [5027](5027.sh) | Ensure SETroubleshoot is not installed | `linux.mac.setroubleshoot_removed` |
| [5028](5028.sh) | Ensure the MCS Translation Service (mcstrans) is not installed | `linux.mac.mcstrans_removed` |
| [5029](5029.sh) | Ensure a login warning banner is configured | `linux.banner.login_banner` |
| [5030](5030.sh) | Ensure the login banner does not disclose OS information | `linux.banner.banner_no_os_info` |
| [5031](5031.sh) | Ensure the system clock is synchronized | `linux.time.clock_synchronized` |
| [5032](5032.sh) | Ensure chrony is enabled | `linux.time.chrony_enabled` |
| [5033](5033.sh) | Ensure ntp is enabled | `linux.time.ntp_enabled` |
| [5034](5034.sh) | Ensure xinetd is not installed | `linux.services.xinetd_removed` |
| [5035](5035.sh) | Ensure the X Window System is not installed | `linux.services.xorg_removed` |
| [5036](5036.sh) | Ensure the Avahi server is not enabled | `linux.services.avahi_disabled` |
| [5037](5037.sh) | Ensure CUPS is not enabled | `linux.services.cups_disabled` |
| [5038](5038.sh) | Ensure a DHCP server is not installed | `linux.services.dhcp_server_removed` |
| [5039](5039.sh) | Ensure an LDAP server is not installed | `linux.services.ldap_server_removed` |
| [5040](5040.sh) | Ensure a DNS server is not installed | `linux.services.dns_server_removed` |
| [5041](5041.sh) | Ensure an FTP server is not installed | `linux.services.ftp_server_removed` |
| [5042](5042.sh) | Ensure an HTTP server is not installed | `linux.services.http_server_removed` |
| [5043](5043.sh) | Ensure an IMAP/POP3 server is not installed | `linux.services.imap_pop3_removed` |
| [5044](5044.sh) | Ensure Samba is not installed | `linux.services.samba_removed` |
| [5045](5045.sh) | Ensure an HTTP proxy server is not installed | `linux.services.http_proxy_removed` |
| [5046](5046.sh) | Ensure the NIS server is not installed | `linux.services.nis_server_removed` |
| [5047](5047.sh) | Ensure the telnet server is not installed | `linux.services.telnet_server_removed` |
| [5048](5048.sh) | Ensure the mail transfer agent is configured for local-only mode | `linux.services.mta_local_only` |
| [5049](5049.sh) | Ensure the NFS server is not enabled | `linux.services.nfs_disabled` |
| [5050](5050.sh) | Ensure the NIS client is not installed | `linux.clients.nis_client_removed` |
| [5051](5051.sh) | Ensure the rsh client is not installed | `linux.clients.rsh_removed` |
| [5052](5052.sh) | Ensure the talk client is not installed | `linux.clients.talk_removed` |
| [5053](5053.sh) | Ensure the LDAP client is not installed | `linux.clients.ldap_client_removed` |
| [5054](5054.sh) | Ensure IP forwarding is disabled | `linux.network.ip_forward_disabled` |
| [5055](5055.sh) | Ensure packet redirect sending is disabled | `linux.network.send_redirects_disabled` |
| [5056](5056.sh) | Ensure source routed packets are not accepted | `linux.network.source_route_rejected` |
| [5057](5057.sh) | Ensure ICMP redirects are not accepted | `linux.network.icmp_redirects_rejected` |
| [5058](5058.sh) | Ensure secure ICMP redirects are not accepted | `linux.network.secure_redirects_rejected` |
| [5059](5059.sh) | Ensure suspicious (martian) packets are logged | `linux.network.log_martians` |
| [5060](5060.sh) | Ensure broadcast ICMP requests are ignored | `linux.network.ignore_broadcast_icmp` |
| [5061](5061.sh) | Ensure bogus ICMP responses are ignored | `linux.network.ignore_bogus_icmp` |
| [5062](5062.sh) | Ensure reverse path filtering is enabled | `linux.network.rp_filter` |
| [5063](5063.sh) | Ensure TCP SYN cookies are enabled | `linux.network.tcp_syncookies` |
| [5064](5064.sh) | Ensure TCP Wrappers is installed | `linux.tcp_wrappers.tcp_wrappers_installed` |
| [5065](5065.sh) | Ensure /etc/hosts.allow is configured | `linux.tcp_wrappers.hosts_allow_configured` |
| [5066](5066.sh) | Ensure permissions on /etc/hosts.allow are configured | `linux.tcp_wrappers.hosts_allow_perms` |
| [5067](5067.sh) | Ensure /etc/hosts.deny denies all by default | `linux.tcp_wrappers.hosts_deny_configured` |
| [5068](5068.sh) | Ensure permissions on /etc/hosts.deny are configured | `linux.tcp_wrappers.hosts_deny_perms` |
| [5069](5069.sh) | Ensure a host firewall is enabled | `linux.firewall.firewall_enabled` |
| [5070](5070.sh) | Ensure firewall rules are configured | `linux.firewall.firewall_rules` |
| [5071](5071.sh) | Ensure permissions on /etc/ssh/sshd_config are configured | `linux.ssh.sshd_config_perms` |
| [5072](5072.sh) | Ensure SSH Protocol is set to 2 | `linux.ssh.ssh_protocol_2` |
| [5073](5073.sh) | Ensure SSH LogLevel is INFO or VERBOSE | `linux.ssh.ssh_loglevel` |
| [5074](5074.sh) | Ensure SSH X11 forwarding is disabled | `linux.ssh.ssh_x11_forwarding_disabled` |
| [5075](5075.sh) | Ensure SSH MaxAuthTries is set to 4 or less | `linux.ssh.ssh_max_auth_tries` |
| [5076](5076.sh) | Ensure SSH root login is disabled | `linux.ssh.ssh_root_login_disabled` |
| [5077](5077.sh) | Ensure rsyslog is installed and enabled | `linux.logging.rsyslog_enabled` |
| [5078](5078.sh) | Ensure permissions on log files are configured | `linux.logging.log_file_perms` |
| [5079](5079.sh) | Ensure audit rules are configured | `linux.audit.audit_rules` |
| [5080](5080.sh) | Ensure auditd is installed | `linux.audit.auditd_installed` |
| [5081](5081.sh) | Ensure the auditd service is enabled and running | `linux.audit.auditd_enabled` |
| [5082](5082.sh) | Ensure an account lockout PAM module is configured | `linux.auth.lockout_module` |
| [5083](5083.sh) | Ensure password quality requirements are configured | `linux.auth.pwquality` |
| [5084](5084.sh) | Ensure lockout after failed password attempts is configured | `linux.auth.lockout_deny` |
| [5085](5085.sh) | Ensure password reuse is limited | `linux.auth.password_reuse` |
| [5086](5086.sh) | Ensure the password hashing algorithm is SHA-512 | `linux.auth.password_hash_sha512` |
| [5087](5087.sh) | Ensure password expiration is 90 days or less | `linux.auth.pass_max_days` |
| [5088](5088.sh) | Ensure user password expiration is set | `linux.auth.password_expiry_set` |
| [5089](5089.sh) | Ensure minimum days between password changes is 1 or more | `linux.auth.pass_min_days` |
| [5090](5090.sh) | Ensure password expiration warning is 7 days or more | `linux.auth.pass_warn_age` |
| [5091](5091.sh) | Ensure the inactive password lock (INACTIVE) is configured | `linux.auth.inactive_lock` |

### Inventory collectors (10)

Served by the Go binary: `checklist <id>`.

| ID | Collects | Key |
|---:|---|---|
| 5092 | SSH authorized_keys per user | `collect.ssh_keys` |
| 5093 | Local account names | `collect.accounts` |
| 5094 | Users, groups and sudoers/administrators membership | `collect.users_groups` |
| 5095 | Effective password policy | `collect.password_policy` |
| 5096 | OS, kernel and patch level | `collect.patching` |
| 5097 | SHA-256 checksums of the files given with --files | `collect.file_checksums` |
| 5098 | Files in the directories given with --folders | `collect.file_listing` |
| 5099 | Non-loopback listening TCP/UDP ports | `collect.listening_ports` |
| 5100 | Host firewall rules | `collect.firewall_rules` |
| 5101 | Logging configuration and agent status | `collect.log_config` |

<!-- END GENERATED -->
