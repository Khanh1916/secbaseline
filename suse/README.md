# SUSE Linux Enterprise / openSUSE checks

CIS-style hardening checks for SUSE Linux Enterprise / openSUSE, IDs `200–290`. Inventory collectors `291–300` are served by the Go binary (`checklist <id>`), not by scripts here.

Each script runs on the target host with no arguments, prints optional `INFO:` detail
lines followed by exactly one `PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or
`1` (fail). Most checks read root-only files, so run them as root.

## Usage

Run every check and write a report (from the repository root):

```bash
sudo ./checklist/checklist run --platform suse --html suse-report.html -o suse-report.json
```

`--platform` can be omitted on the host itself; the runner detects the distribution from `/etc/os-release`.

Run one check:

```bash
sudo bash suse/200.sh; echo "exit=$?"
```

## Notes

- IDs are `199 + index` relative to the RHEL family (`200.sh` = RHEL `2001.sh`).
- Uses SUSE package and service names where they differ from RHEL (`openldap2`, `apache2`, `nfsserver`, `xorg-x11-server`, `openldap2-client`) and `/etc/pam.d/common-auth` for PAM.

<!-- BEGIN GENERATED: checklist docs -->

### Controls (91)

| ID | Control | Key |
|---:|---|---|
| [200](200.sh) | Ensure the cramfs kernel module is disabled | `linux.filesystem.cramfs_disabled` |
| [201](201.sh) | Ensure the squashfs kernel module is disabled | `linux.filesystem.squashfs_disabled` |
| [202](202.sh) | Ensure the udf kernel module is disabled | `linux.filesystem.udf_disabled` |
| [203](203.sh) | Ensure /tmp is a separate partition | `linux.filesystem.tmp_partition` |
| [204](204.sh) | Ensure nodev option is set on /tmp | `linux.filesystem.tmp_nodev` |
| [205](205.sh) | Ensure nosuid option is set on /tmp | `linux.filesystem.tmp_nosuid` |
| [206](206.sh) | Ensure noexec option is set on /tmp | `linux.filesystem.tmp_noexec` |
| [207](207.sh) | Ensure /dev/shm is a separate partition | `linux.filesystem.dev_shm_partition` |
| [208](208.sh) | Ensure nodev option is set on /dev/shm | `linux.filesystem.dev_shm_nodev` |
| [209](209.sh) | Ensure nosuid option is set on /dev/shm | `linux.filesystem.dev_shm_nosuid` |
| [210](210.sh) | Ensure noexec option is set on /dev/shm | `linux.filesystem.dev_shm_noexec` |
| [211](211.sh) | Ensure /var is a separate partition | `linux.filesystem.var_partition` |
| [212](212.sh) | Ensure /var/tmp is a separate partition or bound to /tmp | `linux.filesystem.var_tmp_partition` |
| [213](213.sh) | Ensure /var/log is a separate partition | `linux.filesystem.var_log_partition` |
| [214](214.sh) | Ensure /var/log/audit is a separate partition | `linux.filesystem.var_log_audit_partition` |
| [215](215.sh) | Ensure /home is a separate partition | `linux.filesystem.home_partition` |
| [216](216.sh) | Ensure nodev option is set on /home | `linux.filesystem.home_nodev` |
| [217](217.sh) | Ensure sticky bit is set on all world-writable directories | `linux.filesystem.sticky_bit` |
| [218](218.sh) | Ensure AIDE is installed | `linux.integrity.aide_installed` |
| [219](219.sh) | Ensure core dumps are restricted | `linux.hardening.core_dumps_restricted` |
| [220](220.sh) | Ensure address space layout randomization (ASLR) is enabled | `linux.hardening.aslr_enabled` |
| [221](221.sh) | Ensure prelink is not installed | `linux.hardening.prelink_removed` |
| [222](222.sh) | Ensure SELinux is installed | `linux.mac.selinux_installed` |
| [223](223.sh) | Ensure SELinux is not disabled | `linux.mac.selinux_not_disabled` |
| [224](224.sh) | Ensure SELinux mode is enforcing or permissive | `linux.mac.selinux_mode` |
| [225](225.sh) | Ensure SELinux mode is enforcing | `linux.mac.selinux_enforcing` |
| [226](226.sh) | Ensure SETroubleshoot is not installed | `linux.mac.setroubleshoot_removed` |
| [227](227.sh) | Ensure the MCS Translation Service (mcstrans) is not installed | `linux.mac.mcstrans_removed` |
| [228](228.sh) | Ensure a login warning banner is configured | `linux.banner.login_banner` |
| [229](229.sh) | Ensure the login banner does not disclose OS information | `linux.banner.banner_no_os_info` |
| [230](230.sh) | Ensure the system clock is synchronized | `linux.time.clock_synchronized` |
| [231](231.sh) | Ensure chrony is enabled | `linux.time.chrony_enabled` |
| [232](232.sh) | Ensure ntp is enabled | `linux.time.ntp_enabled` |
| [233](233.sh) | Ensure xinetd is not installed | `linux.services.xinetd_removed` |
| [234](234.sh) | Ensure the X Window System is not installed | `linux.services.xorg_removed` |
| [235](235.sh) | Ensure the Avahi server is not enabled | `linux.services.avahi_disabled` |
| [236](236.sh) | Ensure CUPS is not enabled | `linux.services.cups_disabled` |
| [237](237.sh) | Ensure a DHCP server is not installed | `linux.services.dhcp_server_removed` |
| [238](238.sh) | Ensure an LDAP server is not installed | `linux.services.ldap_server_removed` |
| [239](239.sh) | Ensure a DNS server is not installed | `linux.services.dns_server_removed` |
| [240](240.sh) | Ensure an FTP server is not installed | `linux.services.ftp_server_removed` |
| [241](241.sh) | Ensure an HTTP server is not installed | `linux.services.http_server_removed` |
| [242](242.sh) | Ensure an IMAP/POP3 server is not installed | `linux.services.imap_pop3_removed` |
| [243](243.sh) | Ensure Samba is not installed | `linux.services.samba_removed` |
| [244](244.sh) | Ensure an HTTP proxy server is not installed | `linux.services.http_proxy_removed` |
| [245](245.sh) | Ensure the NIS server is not installed | `linux.services.nis_server_removed` |
| [246](246.sh) | Ensure the telnet server is not installed | `linux.services.telnet_server_removed` |
| [247](247.sh) | Ensure the mail transfer agent is configured for local-only mode | `linux.services.mta_local_only` |
| [248](248.sh) | Ensure the NFS server is not enabled | `linux.services.nfs_disabled` |
| [249](249.sh) | Ensure the NIS client is not installed | `linux.clients.nis_client_removed` |
| [250](250.sh) | Ensure the rsh client is not installed | `linux.clients.rsh_removed` |
| [251](251.sh) | Ensure the talk client is not installed | `linux.clients.talk_removed` |
| [252](252.sh) | Ensure the LDAP client is not installed | `linux.clients.ldap_client_removed` |
| [253](253.sh) | Ensure IP forwarding is disabled | `linux.network.ip_forward_disabled` |
| [254](254.sh) | Ensure packet redirect sending is disabled | `linux.network.send_redirects_disabled` |
| [255](255.sh) | Ensure source routed packets are not accepted | `linux.network.source_route_rejected` |
| [256](256.sh) | Ensure ICMP redirects are not accepted | `linux.network.icmp_redirects_rejected` |
| [257](257.sh) | Ensure secure ICMP redirects are not accepted | `linux.network.secure_redirects_rejected` |
| [258](258.sh) | Ensure suspicious (martian) packets are logged | `linux.network.log_martians` |
| [259](259.sh) | Ensure broadcast ICMP requests are ignored | `linux.network.ignore_broadcast_icmp` |
| [260](260.sh) | Ensure bogus ICMP responses are ignored | `linux.network.ignore_bogus_icmp` |
| [261](261.sh) | Ensure reverse path filtering is enabled | `linux.network.rp_filter` |
| [262](262.sh) | Ensure TCP SYN cookies are enabled | `linux.network.tcp_syncookies` |
| [263](263.sh) | Ensure TCP Wrappers is installed | `linux.tcp_wrappers.tcp_wrappers_installed` |
| [264](264.sh) | Ensure /etc/hosts.allow is configured | `linux.tcp_wrappers.hosts_allow_configured` |
| [265](265.sh) | Ensure permissions on /etc/hosts.allow are configured | `linux.tcp_wrappers.hosts_allow_perms` |
| [266](266.sh) | Ensure /etc/hosts.deny denies all by default | `linux.tcp_wrappers.hosts_deny_configured` |
| [267](267.sh) | Ensure permissions on /etc/hosts.deny are configured | `linux.tcp_wrappers.hosts_deny_perms` |
| [268](268.sh) | Ensure a host firewall is enabled | `linux.firewall.firewall_enabled` |
| [269](269.sh) | Ensure firewall rules are configured | `linux.firewall.firewall_rules` |
| [270](270.sh) | Ensure permissions on /etc/ssh/sshd_config are configured | `linux.ssh.sshd_config_perms` |
| [271](271.sh) | Ensure SSH Protocol is set to 2 | `linux.ssh.ssh_protocol_2` |
| [272](272.sh) | Ensure SSH LogLevel is INFO or VERBOSE | `linux.ssh.ssh_loglevel` |
| [273](273.sh) | Ensure SSH X11 forwarding is disabled | `linux.ssh.ssh_x11_forwarding_disabled` |
| [274](274.sh) | Ensure SSH MaxAuthTries is set to 4 or less | `linux.ssh.ssh_max_auth_tries` |
| [275](275.sh) | Ensure SSH root login is disabled | `linux.ssh.ssh_root_login_disabled` |
| [276](276.sh) | Ensure rsyslog is installed and enabled | `linux.logging.rsyslog_enabled` |
| [277](277.sh) | Ensure permissions on log files are configured | `linux.logging.log_file_perms` |
| [278](278.sh) | Ensure audit rules are configured | `linux.audit.audit_rules` |
| [279](279.sh) | Ensure auditd is installed | `linux.audit.auditd_installed` |
| [280](280.sh) | Ensure the auditd service is enabled and running | `linux.audit.auditd_enabled` |
| [281](281.sh) | Ensure an account lockout PAM module is configured | `linux.auth.lockout_module` |
| [282](282.sh) | Ensure password quality requirements are configured | `linux.auth.pwquality` |
| [283](283.sh) | Ensure lockout after failed password attempts is configured | `linux.auth.lockout_deny` |
| [284](284.sh) | Ensure password reuse is limited | `linux.auth.password_reuse` |
| [285](285.sh) | Ensure the password hashing algorithm is SHA-512 | `linux.auth.password_hash_sha512` |
| [286](286.sh) | Ensure password expiration is 90 days or less | `linux.auth.pass_max_days` |
| [287](287.sh) | Ensure user password expiration is set | `linux.auth.password_expiry_set` |
| [288](288.sh) | Ensure minimum days between password changes is 1 or more | `linux.auth.pass_min_days` |
| [289](289.sh) | Ensure password expiration warning is 7 days or more | `linux.auth.pass_warn_age` |
| [290](290.sh) | Ensure the inactive password lock (INACTIVE) is configured | `linux.auth.inactive_lock` |

### Inventory collectors (10)

Served by the Go binary: `checklist <id>`.

| ID | Collects | Key |
|---:|---|---|
| 291 | SSH authorized_keys per user | `collect.ssh_keys` |
| 292 | Local account names | `collect.accounts` |
| 293 | Users, groups and sudoers/administrators membership | `collect.users_groups` |
| 294 | Effective password policy | `collect.password_policy` |
| 295 | OS, kernel and patch level | `collect.patching` |
| 296 | SHA-256 checksums of the files given with --files | `collect.file_checksums` |
| 297 | Files in the directories given with --folders | `collect.file_listing` |
| 298 | Non-loopback listening TCP/UDP ports | `collect.listening_ports` |
| 299 | Host firewall rules | `collect.firewall_rules` |
| 300 | Logging configuration and agent status | `collect.log_config` |

<!-- END GENERATED -->
