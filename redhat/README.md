# Red Hat Enterprise Linux checks

CIS-style hardening checks for Red Hat Enterprise Linux, IDs `2001–2091`. Inventory collectors `2092–2101` are served by the Go binary (`checklist <id>`), not by scripts here.

Each script runs on the target host with no arguments, prints optional `INFO:` detail
lines followed by exactly one `PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or
`1` (fail). Most checks read root-only files, so run them as root.

## Usage

Run every check and write a report (from the repository root):

```bash
sudo ./checklist/checklist run --platform redhat --html redhat-report.html -o redhat-report.json
```

`--platform` can be omitted on the host itself; the runner detects the distribution from `/etc/os-release`.

Run one check:

```bash
sudo bash redhat/2001.sh; echo "exit=$?"
```

## Notes

- This is the reference implementation for the RHEL family: [`../rocky`](../rocky), [`../centos`](../centos), [`../oraclelinux`](../oraclelinux) and [`../suse`](../suse) are derived from it. Change a control here first, then mirror it under the same key in the other directories.
- Package checks use `rpm -q`; mount checks use `findmnt`; SELinux checks use `sestatus`.

<!-- BEGIN GENERATED: checklist docs -->

### Controls (91)

| ID | Control | Key |
|---:|---|---|
| [2001](2001.sh) | Ensure the cramfs kernel module is disabled | `linux.filesystem.cramfs_disabled` |
| [2002](2002.sh) | Ensure the squashfs kernel module is disabled | `linux.filesystem.squashfs_disabled` |
| [2003](2003.sh) | Ensure the udf kernel module is disabled | `linux.filesystem.udf_disabled` |
| [2004](2004.sh) | Ensure /tmp is a separate partition | `linux.filesystem.tmp_partition` |
| [2005](2005.sh) | Ensure nodev option is set on /tmp | `linux.filesystem.tmp_nodev` |
| [2006](2006.sh) | Ensure nosuid option is set on /tmp | `linux.filesystem.tmp_nosuid` |
| [2007](2007.sh) | Ensure noexec option is set on /tmp | `linux.filesystem.tmp_noexec` |
| [2008](2008.sh) | Ensure /dev/shm is a separate partition | `linux.filesystem.dev_shm_partition` |
| [2009](2009.sh) | Ensure nodev option is set on /dev/shm | `linux.filesystem.dev_shm_nodev` |
| [2010](2010.sh) | Ensure nosuid option is set on /dev/shm | `linux.filesystem.dev_shm_nosuid` |
| [2011](2011.sh) | Ensure noexec option is set on /dev/shm | `linux.filesystem.dev_shm_noexec` |
| [2012](2012.sh) | Ensure /var is a separate partition | `linux.filesystem.var_partition` |
| [2013](2013.sh) | Ensure /var/tmp is a separate partition or bound to /tmp | `linux.filesystem.var_tmp_partition` |
| [2014](2014.sh) | Ensure /var/log is a separate partition | `linux.filesystem.var_log_partition` |
| [2015](2015.sh) | Ensure /var/log/audit is a separate partition | `linux.filesystem.var_log_audit_partition` |
| [2016](2016.sh) | Ensure /home is a separate partition | `linux.filesystem.home_partition` |
| [2017](2017.sh) | Ensure nodev option is set on /home | `linux.filesystem.home_nodev` |
| [2018](2018.sh) | Ensure sticky bit is set on all world-writable directories | `linux.filesystem.sticky_bit` |
| [2019](2019.sh) | Ensure AIDE is installed | `linux.integrity.aide_installed` |
| [2020](2020.sh) | Ensure core dumps are restricted | `linux.hardening.core_dumps_restricted` |
| [2021](2021.sh) | Ensure address space layout randomization (ASLR) is enabled | `linux.hardening.aslr_enabled` |
| [2022](2022.sh) | Ensure prelink is not installed | `linux.hardening.prelink_removed` |
| [2023](2023.sh) | Ensure SELinux is installed | `linux.mac.selinux_installed` |
| [2024](2024.sh) | Ensure SELinux is not disabled | `linux.mac.selinux_not_disabled` |
| [2025](2025.sh) | Ensure SELinux mode is enforcing or permissive | `linux.mac.selinux_mode` |
| [2026](2026.sh) | Ensure SELinux mode is enforcing | `linux.mac.selinux_enforcing` |
| [2027](2027.sh) | Ensure SETroubleshoot is not installed | `linux.mac.setroubleshoot_removed` |
| [2028](2028.sh) | Ensure the MCS Translation Service (mcstrans) is not installed | `linux.mac.mcstrans_removed` |
| [2029](2029.sh) | Ensure a login warning banner is configured | `linux.banner.login_banner` |
| [2030](2030.sh) | Ensure the login banner does not disclose OS information | `linux.banner.banner_no_os_info` |
| [2031](2031.sh) | Ensure the system clock is synchronized | `linux.time.clock_synchronized` |
| [2032](2032.sh) | Ensure chrony is enabled | `linux.time.chrony_enabled` |
| [2033](2033.sh) | Ensure ntp is enabled | `linux.time.ntp_enabled` |
| [2034](2034.sh) | Ensure xinetd is not installed | `linux.services.xinetd_removed` |
| [2035](2035.sh) | Ensure the X Window System is not installed | `linux.services.xorg_removed` |
| [2036](2036.sh) | Ensure the Avahi server is not enabled | `linux.services.avahi_disabled` |
| [2037](2037.sh) | Ensure CUPS is not enabled | `linux.services.cups_disabled` |
| [2038](2038.sh) | Ensure a DHCP server is not installed | `linux.services.dhcp_server_removed` |
| [2039](2039.sh) | Ensure an LDAP server is not installed | `linux.services.ldap_server_removed` |
| [2040](2040.sh) | Ensure a DNS server is not installed | `linux.services.dns_server_removed` |
| [2041](2041.sh) | Ensure an FTP server is not installed | `linux.services.ftp_server_removed` |
| [2042](2042.sh) | Ensure an HTTP server is not installed | `linux.services.http_server_removed` |
| [2043](2043.sh) | Ensure an IMAP/POP3 server is not installed | `linux.services.imap_pop3_removed` |
| [2044](2044.sh) | Ensure Samba is not installed | `linux.services.samba_removed` |
| [2045](2045.sh) | Ensure an HTTP proxy server is not installed | `linux.services.http_proxy_removed` |
| [2046](2046.sh) | Ensure the NIS server is not installed | `linux.services.nis_server_removed` |
| [2047](2047.sh) | Ensure the telnet server is not installed | `linux.services.telnet_server_removed` |
| [2048](2048.sh) | Ensure the mail transfer agent is configured for local-only mode | `linux.services.mta_local_only` |
| [2049](2049.sh) | Ensure the NFS server is not enabled | `linux.services.nfs_disabled` |
| [2050](2050.sh) | Ensure the NIS client is not installed | `linux.clients.nis_client_removed` |
| [2051](2051.sh) | Ensure the rsh client is not installed | `linux.clients.rsh_removed` |
| [2052](2052.sh) | Ensure the talk client is not installed | `linux.clients.talk_removed` |
| [2053](2053.sh) | Ensure the LDAP client is not installed | `linux.clients.ldap_client_removed` |
| [2054](2054.sh) | Ensure IP forwarding is disabled | `linux.network.ip_forward_disabled` |
| [2055](2055.sh) | Ensure packet redirect sending is disabled | `linux.network.send_redirects_disabled` |
| [2056](2056.sh) | Ensure source routed packets are not accepted | `linux.network.source_route_rejected` |
| [2057](2057.sh) | Ensure ICMP redirects are not accepted | `linux.network.icmp_redirects_rejected` |
| [2058](2058.sh) | Ensure secure ICMP redirects are not accepted | `linux.network.secure_redirects_rejected` |
| [2059](2059.sh) | Ensure suspicious (martian) packets are logged | `linux.network.log_martians` |
| [2060](2060.sh) | Ensure broadcast ICMP requests are ignored | `linux.network.ignore_broadcast_icmp` |
| [2061](2061.sh) | Ensure bogus ICMP responses are ignored | `linux.network.ignore_bogus_icmp` |
| [2062](2062.sh) | Ensure reverse path filtering is enabled | `linux.network.rp_filter` |
| [2063](2063.sh) | Ensure TCP SYN cookies are enabled | `linux.network.tcp_syncookies` |
| [2064](2064.sh) | Ensure TCP Wrappers is installed | `linux.tcp_wrappers.tcp_wrappers_installed` |
| [2065](2065.sh) | Ensure /etc/hosts.allow is configured | `linux.tcp_wrappers.hosts_allow_configured` |
| [2066](2066.sh) | Ensure permissions on /etc/hosts.allow are configured | `linux.tcp_wrappers.hosts_allow_perms` |
| [2067](2067.sh) | Ensure /etc/hosts.deny denies all by default | `linux.tcp_wrappers.hosts_deny_configured` |
| [2068](2068.sh) | Ensure permissions on /etc/hosts.deny are configured | `linux.tcp_wrappers.hosts_deny_perms` |
| [2069](2069.sh) | Ensure a host firewall is enabled | `linux.firewall.firewall_enabled` |
| [2070](2070.sh) | Ensure firewall rules are configured | `linux.firewall.firewall_rules` |
| [2071](2071.sh) | Ensure permissions on /etc/ssh/sshd_config are configured | `linux.ssh.sshd_config_perms` |
| [2072](2072.sh) | Ensure SSH Protocol is set to 2 | `linux.ssh.ssh_protocol_2` |
| [2073](2073.sh) | Ensure SSH LogLevel is INFO or VERBOSE | `linux.ssh.ssh_loglevel` |
| [2074](2074.sh) | Ensure SSH X11 forwarding is disabled | `linux.ssh.ssh_x11_forwarding_disabled` |
| [2075](2075.sh) | Ensure SSH MaxAuthTries is set to 4 or less | `linux.ssh.ssh_max_auth_tries` |
| [2076](2076.sh) | Ensure SSH root login is disabled | `linux.ssh.ssh_root_login_disabled` |
| [2077](2077.sh) | Ensure rsyslog is installed and enabled | `linux.logging.rsyslog_enabled` |
| [2078](2078.sh) | Ensure permissions on log files are configured | `linux.logging.log_file_perms` |
| [2079](2079.sh) | Ensure audit rules are configured | `linux.audit.audit_rules` |
| [2080](2080.sh) | Ensure auditd is installed | `linux.audit.auditd_installed` |
| [2081](2081.sh) | Ensure the auditd service is enabled and running | `linux.audit.auditd_enabled` |
| [2082](2082.sh) | Ensure an account lockout PAM module is configured | `linux.auth.lockout_module` |
| [2083](2083.sh) | Ensure password quality requirements are configured | `linux.auth.pwquality` |
| [2084](2084.sh) | Ensure lockout after failed password attempts is configured | `linux.auth.lockout_deny` |
| [2085](2085.sh) | Ensure password reuse is limited | `linux.auth.password_reuse` |
| [2086](2086.sh) | Ensure the password hashing algorithm is SHA-512 or yescrypt | `linux.auth.password_hash_sha512` |
| [2087](2087.sh) | Ensure password expiration is 90 days or less | `linux.auth.pass_max_days` |
| [2088](2088.sh) | Ensure user password expiration is set | `linux.auth.password_expiry_set` |
| [2089](2089.sh) | Ensure minimum days between password changes is 1 or more | `linux.auth.pass_min_days` |
| [2090](2090.sh) | Ensure password expiration warning is 7 days or more | `linux.auth.pass_warn_age` |
| [2091](2091.sh) | Ensure the inactive password lock (INACTIVE) is configured | `linux.auth.inactive_lock` |

### Inventory collectors (10)

Served by the Go binary: `checklist <id>`.

| ID | Collects | Key |
|---:|---|---|
| 2092 | SSH authorized_keys per user | `collect.ssh_keys` |
| 2093 | Local account names | `collect.accounts` |
| 2094 | Users, groups and sudoers/administrators membership | `collect.users_groups` |
| 2095 | Effective password policy | `collect.password_policy` |
| 2096 | OS, kernel and patch level | `collect.patching` |
| 2097 | SHA-256 checksums of the files given with --files | `collect.file_checksums` |
| 2098 | Files in the directories given with --folders | `collect.file_listing` |
| 2099 | Non-loopback listening TCP/UDP ports | `collect.listening_ports` |
| 2100 | Host firewall rules | `collect.firewall_rules` |
| 2101 | Logging configuration and agent status | `collect.log_config` |

<!-- END GENERATED -->
