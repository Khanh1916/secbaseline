# Rocky Linux checks

CIS-style hardening checks for Rocky Linux, IDs `3001–3091`. Inventory collectors `3092–3101` are served by the Go binary (`checklist <id>`), not by scripts here.

Each script runs on the target host with no arguments, prints optional `INFO:` detail
lines followed by exactly one `PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or
`1` (fail). Most checks read root-only files, so run them as root.

## Usage

Run every check and write a report (from the repository root):

```bash
sudo ./checklist/checklist run --platform rocky --html rocky-report.html -o rocky-report.json
```

`--platform` can be omitted on the host itself; the runner detects the distribution from `/etc/os-release`.

Run one check:

```bash
sudo bash rocky/3001.sh; echo "exit=$?"
```

## Notes

- Identical to [`../redhat`](../redhat) except `3030.sh`, whose banner check looks for "Rocky".

<!-- BEGIN GENERATED: checklist docs -->

### Controls (91)

| ID | Control | Key |
|---:|---|---|
| [3001](3001.sh) | Ensure the cramfs kernel module is disabled | `linux.filesystem.cramfs_disabled` |
| [3002](3002.sh) | Ensure the squashfs kernel module is disabled | `linux.filesystem.squashfs_disabled` |
| [3003](3003.sh) | Ensure the udf kernel module is disabled | `linux.filesystem.udf_disabled` |
| [3004](3004.sh) | Ensure /tmp is a separate partition | `linux.filesystem.tmp_partition` |
| [3005](3005.sh) | Ensure nodev option is set on /tmp | `linux.filesystem.tmp_nodev` |
| [3006](3006.sh) | Ensure nosuid option is set on /tmp | `linux.filesystem.tmp_nosuid` |
| [3007](3007.sh) | Ensure noexec option is set on /tmp | `linux.filesystem.tmp_noexec` |
| [3008](3008.sh) | Ensure /dev/shm is a separate partition | `linux.filesystem.dev_shm_partition` |
| [3009](3009.sh) | Ensure nodev option is set on /dev/shm | `linux.filesystem.dev_shm_nodev` |
| [3010](3010.sh) | Ensure nosuid option is set on /dev/shm | `linux.filesystem.dev_shm_nosuid` |
| [3011](3011.sh) | Ensure noexec option is set on /dev/shm | `linux.filesystem.dev_shm_noexec` |
| [3012](3012.sh) | Ensure /var is a separate partition | `linux.filesystem.var_partition` |
| [3013](3013.sh) | Ensure /var/tmp is a separate partition or bound to /tmp | `linux.filesystem.var_tmp_partition` |
| [3014](3014.sh) | Ensure /var/log is a separate partition | `linux.filesystem.var_log_partition` |
| [3015](3015.sh) | Ensure /var/log/audit is a separate partition | `linux.filesystem.var_log_audit_partition` |
| [3016](3016.sh) | Ensure /home is a separate partition | `linux.filesystem.home_partition` |
| [3017](3017.sh) | Ensure nodev option is set on /home | `linux.filesystem.home_nodev` |
| [3018](3018.sh) | Ensure sticky bit is set on all world-writable directories | `linux.filesystem.sticky_bit` |
| [3019](3019.sh) | Ensure AIDE is installed | `linux.integrity.aide_installed` |
| [3020](3020.sh) | Ensure core dumps are restricted | `linux.hardening.core_dumps_restricted` |
| [3021](3021.sh) | Ensure address space layout randomization (ASLR) is enabled | `linux.hardening.aslr_enabled` |
| [3022](3022.sh) | Ensure prelink is not installed | `linux.hardening.prelink_removed` |
| [3023](3023.sh) | Ensure SELinux is installed | `linux.mac.selinux_installed` |
| [3024](3024.sh) | Ensure SELinux is not disabled | `linux.mac.selinux_not_disabled` |
| [3025](3025.sh) | Ensure SELinux mode is enforcing or permissive | `linux.mac.selinux_mode` |
| [3026](3026.sh) | Ensure SELinux mode is enforcing | `linux.mac.selinux_enforcing` |
| [3027](3027.sh) | Ensure SETroubleshoot is not installed | `linux.mac.setroubleshoot_removed` |
| [3028](3028.sh) | Ensure the MCS Translation Service (mcstrans) is not installed | `linux.mac.mcstrans_removed` |
| [3029](3029.sh) | Ensure a login warning banner is configured | `linux.banner.login_banner` |
| [3030](3030.sh) | Ensure the login banner does not disclose OS information | `linux.banner.banner_no_os_info` |
| [3031](3031.sh) | Ensure the system clock is synchronized | `linux.time.clock_synchronized` |
| [3032](3032.sh) | Ensure chrony is enabled | `linux.time.chrony_enabled` |
| [3033](3033.sh) | Ensure ntp is enabled | `linux.time.ntp_enabled` |
| [3034](3034.sh) | Ensure xinetd is not installed | `linux.services.xinetd_removed` |
| [3035](3035.sh) | Ensure the X Window System is not installed | `linux.services.xorg_removed` |
| [3036](3036.sh) | Ensure the Avahi server is not enabled | `linux.services.avahi_disabled` |
| [3037](3037.sh) | Ensure CUPS is not enabled | `linux.services.cups_disabled` |
| [3038](3038.sh) | Ensure a DHCP server is not installed | `linux.services.dhcp_server_removed` |
| [3039](3039.sh) | Ensure an LDAP server is not installed | `linux.services.ldap_server_removed` |
| [3040](3040.sh) | Ensure a DNS server is not installed | `linux.services.dns_server_removed` |
| [3041](3041.sh) | Ensure an FTP server is not installed | `linux.services.ftp_server_removed` |
| [3042](3042.sh) | Ensure an HTTP server is not installed | `linux.services.http_server_removed` |
| [3043](3043.sh) | Ensure an IMAP/POP3 server is not installed | `linux.services.imap_pop3_removed` |
| [3044](3044.sh) | Ensure Samba is not installed | `linux.services.samba_removed` |
| [3045](3045.sh) | Ensure an HTTP proxy server is not installed | `linux.services.http_proxy_removed` |
| [3046](3046.sh) | Ensure the NIS server is not installed | `linux.services.nis_server_removed` |
| [3047](3047.sh) | Ensure the telnet server is not installed | `linux.services.telnet_server_removed` |
| [3048](3048.sh) | Ensure the mail transfer agent is configured for local-only mode | `linux.services.mta_local_only` |
| [3049](3049.sh) | Ensure the NFS server is not enabled | `linux.services.nfs_disabled` |
| [3050](3050.sh) | Ensure the NIS client is not installed | `linux.clients.nis_client_removed` |
| [3051](3051.sh) | Ensure the rsh client is not installed | `linux.clients.rsh_removed` |
| [3052](3052.sh) | Ensure the talk client is not installed | `linux.clients.talk_removed` |
| [3053](3053.sh) | Ensure the LDAP client is not installed | `linux.clients.ldap_client_removed` |
| [3054](3054.sh) | Ensure IP forwarding is disabled | `linux.network.ip_forward_disabled` |
| [3055](3055.sh) | Ensure packet redirect sending is disabled | `linux.network.send_redirects_disabled` |
| [3056](3056.sh) | Ensure source routed packets are not accepted | `linux.network.source_route_rejected` |
| [3057](3057.sh) | Ensure ICMP redirects are not accepted | `linux.network.icmp_redirects_rejected` |
| [3058](3058.sh) | Ensure secure ICMP redirects are not accepted | `linux.network.secure_redirects_rejected` |
| [3059](3059.sh) | Ensure suspicious (martian) packets are logged | `linux.network.log_martians` |
| [3060](3060.sh) | Ensure broadcast ICMP requests are ignored | `linux.network.ignore_broadcast_icmp` |
| [3061](3061.sh) | Ensure bogus ICMP responses are ignored | `linux.network.ignore_bogus_icmp` |
| [3062](3062.sh) | Ensure reverse path filtering is enabled | `linux.network.rp_filter` |
| [3063](3063.sh) | Ensure TCP SYN cookies are enabled | `linux.network.tcp_syncookies` |
| [3064](3064.sh) | Ensure TCP Wrappers is installed | `linux.tcp_wrappers.tcp_wrappers_installed` |
| [3065](3065.sh) | Ensure /etc/hosts.allow is configured | `linux.tcp_wrappers.hosts_allow_configured` |
| [3066](3066.sh) | Ensure permissions on /etc/hosts.allow are configured | `linux.tcp_wrappers.hosts_allow_perms` |
| [3067](3067.sh) | Ensure /etc/hosts.deny denies all by default | `linux.tcp_wrappers.hosts_deny_configured` |
| [3068](3068.sh) | Ensure permissions on /etc/hosts.deny are configured | `linux.tcp_wrappers.hosts_deny_perms` |
| [3069](3069.sh) | Ensure a host firewall is enabled | `linux.firewall.firewall_enabled` |
| [3070](3070.sh) | Ensure firewall rules are configured | `linux.firewall.firewall_rules` |
| [3071](3071.sh) | Ensure permissions on /etc/ssh/sshd_config are configured | `linux.ssh.sshd_config_perms` |
| [3072](3072.sh) | Ensure SSH Protocol is set to 2 | `linux.ssh.ssh_protocol_2` |
| [3073](3073.sh) | Ensure SSH LogLevel is INFO or VERBOSE | `linux.ssh.ssh_loglevel` |
| [3074](3074.sh) | Ensure SSH X11 forwarding is disabled | `linux.ssh.ssh_x11_forwarding_disabled` |
| [3075](3075.sh) | Ensure SSH MaxAuthTries is set to 4 or less | `linux.ssh.ssh_max_auth_tries` |
| [3076](3076.sh) | Ensure SSH root login is disabled | `linux.ssh.ssh_root_login_disabled` |
| [3077](3077.sh) | Ensure rsyslog is installed and enabled | `linux.logging.rsyslog_enabled` |
| [3078](3078.sh) | Ensure permissions on log files are configured | `linux.logging.log_file_perms` |
| [3079](3079.sh) | Ensure audit rules are configured | `linux.audit.audit_rules` |
| [3080](3080.sh) | Ensure auditd is installed | `linux.audit.auditd_installed` |
| [3081](3081.sh) | Ensure the auditd service is enabled and running | `linux.audit.auditd_enabled` |
| [3082](3082.sh) | Ensure an account lockout PAM module is configured | `linux.auth.lockout_module` |
| [3083](3083.sh) | Ensure password quality requirements are configured | `linux.auth.pwquality` |
| [3084](3084.sh) | Ensure lockout after failed password attempts is configured | `linux.auth.lockout_deny` |
| [3085](3085.sh) | Ensure password reuse is limited | `linux.auth.password_reuse` |
| [3086](3086.sh) | Ensure the password hashing algorithm is SHA-512 or yescrypt | `linux.auth.password_hash_sha512` |
| [3087](3087.sh) | Ensure password expiration is 90 days or less | `linux.auth.pass_max_days` |
| [3088](3088.sh) | Ensure user password expiration is set | `linux.auth.password_expiry_set` |
| [3089](3089.sh) | Ensure minimum days between password changes is 1 or more | `linux.auth.pass_min_days` |
| [3090](3090.sh) | Ensure password expiration warning is 7 days or more | `linux.auth.pass_warn_age` |
| [3091](3091.sh) | Ensure the inactive password lock (INACTIVE) is configured | `linux.auth.inactive_lock` |

### Inventory collectors (10)

Served by the Go binary: `checklist <id>`.

| ID | Collects | Key |
|---:|---|---|
| 3092 | SSH authorized_keys per user | `collect.ssh_keys` |
| 3093 | Local account names | `collect.accounts` |
| 3094 | Users, groups and sudoers/administrators membership | `collect.users_groups` |
| 3095 | Effective password policy | `collect.password_policy` |
| 3096 | OS, kernel and patch level | `collect.patching` |
| 3097 | SHA-256 checksums of the files given with --files | `collect.file_checksums` |
| 3098 | Files in the directories given with --folders | `collect.file_listing` |
| 3099 | Non-loopback listening TCP/UDP ports | `collect.listening_ports` |
| 3100 | Host firewall rules | `collect.firewall_rules` |
| 3101 | Logging configuration and agent status | `collect.log_config` |

<!-- END GENERATED -->
