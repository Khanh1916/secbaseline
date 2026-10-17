# Oracle Linux checks

CIS-style hardening checks for Oracle Linux, IDs `100–190`. 

Each script runs on the target host with no arguments, prints optional `INFO:` detail
lines followed by exactly one `PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or
`1` (fail). Most checks read root-only files, so run them as root.

## Usage

Run every check and write a report (from the repository root):

```bash
sudo ./checklist/checklist run --platform oraclelinux --html oraclelinux-report.html -o oraclelinux-report.json
```

`--platform` can be omitted on the host itself; the runner detects the distribution from `/etc/os-release`.

Run one check:

```bash
sudo bash oraclelinux/100.sh; echo "exit=$?"
```

## Notes

- IDs are `99 + index` relative to the RHEL family (`100.sh` = RHEL `2001.sh`).
- The banner check `129.sh` looks for "Oracle Linux".
- No inventory collector IDs are assigned to Oracle Linux yet, so `checklist run` executes checks only.

<!-- BEGIN GENERATED: checklist docs -->

### Controls (91)

| ID | Control | Key |
|---:|---|---|
| [100](100.sh) | Ensure the cramfs kernel module is disabled | `linux.filesystem.cramfs_disabled` |
| [101](101.sh) | Ensure the squashfs kernel module is disabled | `linux.filesystem.squashfs_disabled` |
| [102](102.sh) | Ensure the udf kernel module is disabled | `linux.filesystem.udf_disabled` |
| [103](103.sh) | Ensure /tmp is a separate partition | `linux.filesystem.tmp_partition` |
| [104](104.sh) | Ensure nodev option is set on /tmp | `linux.filesystem.tmp_nodev` |
| [105](105.sh) | Ensure nosuid option is set on /tmp | `linux.filesystem.tmp_nosuid` |
| [106](106.sh) | Ensure noexec option is set on /tmp | `linux.filesystem.tmp_noexec` |
| [107](107.sh) | Ensure /dev/shm is a separate partition | `linux.filesystem.dev_shm_partition` |
| [108](108.sh) | Ensure nodev option is set on /dev/shm | `linux.filesystem.dev_shm_nodev` |
| [109](109.sh) | Ensure nosuid option is set on /dev/shm | `linux.filesystem.dev_shm_nosuid` |
| [110](110.sh) | Ensure noexec option is set on /dev/shm | `linux.filesystem.dev_shm_noexec` |
| [111](111.sh) | Ensure /var is a separate partition | `linux.filesystem.var_partition` |
| [112](112.sh) | Ensure /var/tmp is a separate partition or bound to /tmp | `linux.filesystem.var_tmp_partition` |
| [113](113.sh) | Ensure /var/log is a separate partition | `linux.filesystem.var_log_partition` |
| [114](114.sh) | Ensure /var/log/audit is a separate partition | `linux.filesystem.var_log_audit_partition` |
| [115](115.sh) | Ensure /home is a separate partition | `linux.filesystem.home_partition` |
| [116](116.sh) | Ensure nodev option is set on /home | `linux.filesystem.home_nodev` |
| [117](117.sh) | Ensure sticky bit is set on all world-writable directories | `linux.filesystem.sticky_bit` |
| [118](118.sh) | Ensure AIDE is installed | `linux.integrity.aide_installed` |
| [119](119.sh) | Ensure core dumps are restricted | `linux.hardening.core_dumps_restricted` |
| [120](120.sh) | Ensure address space layout randomization (ASLR) is enabled | `linux.hardening.aslr_enabled` |
| [121](121.sh) | Ensure prelink is not installed | `linux.hardening.prelink_removed` |
| [122](122.sh) | Ensure SELinux is installed | `linux.mac.selinux_installed` |
| [123](123.sh) | Ensure SELinux is not disabled | `linux.mac.selinux_not_disabled` |
| [124](124.sh) | Ensure SELinux mode is enforcing or permissive | `linux.mac.selinux_mode` |
| [125](125.sh) | Ensure SELinux mode is enforcing | `linux.mac.selinux_enforcing` |
| [126](126.sh) | Ensure SETroubleshoot is not installed | `linux.mac.setroubleshoot_removed` |
| [127](127.sh) | Ensure the MCS Translation Service (mcstrans) is not installed | `linux.mac.mcstrans_removed` |
| [128](128.sh) | Ensure a login warning banner is configured | `linux.banner.login_banner` |
| [129](129.sh) | Ensure the login banner does not disclose OS information | `linux.banner.banner_no_os_info` |
| [130](130.sh) | Ensure the system clock is synchronized | `linux.time.clock_synchronized` |
| [131](131.sh) | Ensure chrony is enabled | `linux.time.chrony_enabled` |
| [132](132.sh) | Ensure ntp is enabled | `linux.time.ntp_enabled` |
| [133](133.sh) | Ensure xinetd is not installed | `linux.services.xinetd_removed` |
| [134](134.sh) | Ensure the X Window System is not installed | `linux.services.xorg_removed` |
| [135](135.sh) | Ensure the Avahi server is not enabled | `linux.services.avahi_disabled` |
| [136](136.sh) | Ensure CUPS is not enabled | `linux.services.cups_disabled` |
| [137](137.sh) | Ensure a DHCP server is not installed | `linux.services.dhcp_server_removed` |
| [138](138.sh) | Ensure an LDAP server is not installed | `linux.services.ldap_server_removed` |
| [139](139.sh) | Ensure a DNS server is not installed | `linux.services.dns_server_removed` |
| [140](140.sh) | Ensure an FTP server is not installed | `linux.services.ftp_server_removed` |
| [141](141.sh) | Ensure an HTTP server is not installed | `linux.services.http_server_removed` |
| [142](142.sh) | Ensure an IMAP/POP3 server is not installed | `linux.services.imap_pop3_removed` |
| [143](143.sh) | Ensure Samba is not installed | `linux.services.samba_removed` |
| [144](144.sh) | Ensure an HTTP proxy server is not installed | `linux.services.http_proxy_removed` |
| [145](145.sh) | Ensure the NIS server is not installed | `linux.services.nis_server_removed` |
| [146](146.sh) | Ensure the telnet server is not installed | `linux.services.telnet_server_removed` |
| [147](147.sh) | Ensure the mail transfer agent is configured for local-only mode | `linux.services.mta_local_only` |
| [148](148.sh) | Ensure the NFS server is not enabled | `linux.services.nfs_disabled` |
| [149](149.sh) | Ensure the NIS client is not installed | `linux.clients.nis_client_removed` |
| [150](150.sh) | Ensure the rsh client is not installed | `linux.clients.rsh_removed` |
| [151](151.sh) | Ensure the talk client is not installed | `linux.clients.talk_removed` |
| [152](152.sh) | Ensure the LDAP client is not installed | `linux.clients.ldap_client_removed` |
| [153](153.sh) | Ensure IP forwarding is disabled | `linux.network.ip_forward_disabled` |
| [154](154.sh) | Ensure packet redirect sending is disabled | `linux.network.send_redirects_disabled` |
| [155](155.sh) | Ensure source routed packets are not accepted | `linux.network.source_route_rejected` |
| [156](156.sh) | Ensure ICMP redirects are not accepted | `linux.network.icmp_redirects_rejected` |
| [157](157.sh) | Ensure secure ICMP redirects are not accepted | `linux.network.secure_redirects_rejected` |
| [158](158.sh) | Ensure suspicious (martian) packets are logged | `linux.network.log_martians` |
| [159](159.sh) | Ensure broadcast ICMP requests are ignored | `linux.network.ignore_broadcast_icmp` |
| [160](160.sh) | Ensure bogus ICMP responses are ignored | `linux.network.ignore_bogus_icmp` |
| [161](161.sh) | Ensure reverse path filtering is enabled | `linux.network.rp_filter` |
| [162](162.sh) | Ensure TCP SYN cookies are enabled | `linux.network.tcp_syncookies` |
| [163](163.sh) | Ensure TCP Wrappers is installed | `linux.tcp_wrappers.tcp_wrappers_installed` |
| [164](164.sh) | Ensure /etc/hosts.allow is configured | `linux.tcp_wrappers.hosts_allow_configured` |
| [165](165.sh) | Ensure permissions on /etc/hosts.allow are configured | `linux.tcp_wrappers.hosts_allow_perms` |
| [166](166.sh) | Ensure /etc/hosts.deny denies all by default | `linux.tcp_wrappers.hosts_deny_configured` |
| [167](167.sh) | Ensure permissions on /etc/hosts.deny are configured | `linux.tcp_wrappers.hosts_deny_perms` |
| [168](168.sh) | Ensure a host firewall is enabled | `linux.firewall.firewall_enabled` |
| [169](169.sh) | Ensure firewall rules are configured | `linux.firewall.firewall_rules` |
| [170](170.sh) | Ensure permissions on /etc/ssh/sshd_config are configured | `linux.ssh.sshd_config_perms` |
| [171](171.sh) | Ensure SSH Protocol is set to 2 | `linux.ssh.ssh_protocol_2` |
| [172](172.sh) | Ensure SSH LogLevel is INFO or VERBOSE | `linux.ssh.ssh_loglevel` |
| [173](173.sh) | Ensure SSH X11 forwarding is disabled | `linux.ssh.ssh_x11_forwarding_disabled` |
| [174](174.sh) | Ensure SSH MaxAuthTries is set to 4 or less | `linux.ssh.ssh_max_auth_tries` |
| [175](175.sh) | Ensure SSH root login is disabled | `linux.ssh.ssh_root_login_disabled` |
| [176](176.sh) | Ensure rsyslog is installed and enabled | `linux.logging.rsyslog_enabled` |
| [177](177.sh) | Ensure permissions on log files are configured | `linux.logging.log_file_perms` |
| [178](178.sh) | Ensure audit rules are configured | `linux.audit.audit_rules` |
| [179](179.sh) | Ensure auditd is installed | `linux.audit.auditd_installed` |
| [180](180.sh) | Ensure the auditd service is enabled and running | `linux.audit.auditd_enabled` |
| [181](181.sh) | Ensure an account lockout PAM module is configured | `linux.auth.lockout_module` |
| [182](182.sh) | Ensure password quality requirements are configured | `linux.auth.pwquality` |
| [183](183.sh) | Ensure lockout after failed password attempts is configured | `linux.auth.lockout_deny` |
| [184](184.sh) | Ensure password reuse is limited | `linux.auth.password_reuse` |
| [185](185.sh) | Ensure the password hashing algorithm is SHA-512 | `linux.auth.password_hash_sha512` |
| [186](186.sh) | Ensure password expiration is 90 days or less | `linux.auth.pass_max_days` |
| [187](187.sh) | Ensure user password expiration is set | `linux.auth.password_expiry_set` |
| [188](188.sh) | Ensure minimum days between password changes is 1 or more | `linux.auth.pass_min_days` |
| [189](189.sh) | Ensure password expiration warning is 7 days or more | `linux.auth.pass_warn_age` |
| [190](190.sh) | Ensure the inactive password lock (INACTIVE) is configured | `linux.auth.inactive_lock` |

<!-- END GENERATED -->
