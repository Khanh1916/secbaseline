# Windows checks

Security baseline checks for Microsoft Windows, IDs `4001–4026` and `4037–4054`. Inventory collectors `4027–4036`
are served by the Go binary (`checklist <id>`), not by scripts here.

Each PowerShell script runs on the target host with no arguments, prints exactly one
`PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or `1` (fail).

## Usage

Run from an **elevated** PowerShell prompt: `secedit` and `auditpol` need Administrator rights, and
without them the affected checks report `FAIL` with the reason.

```powershell
.\checklist\checklist.exe run --html windows-report.html -o windows-report.json
```

Run one check:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File windows\4001.ps1; "exit=$LASTEXITCODE"
```

## Notes

- The checks work in any display language. Password and lockout checks (`4001`–`4006`) read the
  local security policy exported by `secedit`; without elevation, `4001`, `4003`, `4005` and `4006`
  fall back to `net accounts`, read by field position rather than by its localized labels.
- Audit checks (`4010`–`4024`) read `auditpol /backup`, which identifies subcategories by GUID and
  settings by number. A subcategory set to Success and Failure includes Success.
- Checks that use `secedit` or `auditpol` export the policy to a temporary file and delete it
  afterwards.
- `4026.ps1` uses `Get-WBPolicy`, which exists only where Windows Server Backup is installed.

<!-- BEGIN GENERATED: checklist docs -->

### Controls (44)

| ID | Control | Key |
|---:|---|---|
| [4001](4001.ps1) | Ensure minimum password length is 8 or more characters | `windows.password.min_length` |
| [4002](4002.ps1) | Ensure password complexity requirements are enabled | `windows.password.complexity` |
| [4003](4003.ps1) | Ensure password history remembers 24 or more passwords | `windows.password.history` |
| [4004](4004.ps1) | Ensure passwords are not stored using reversible encryption | `windows.password.no_reversible_encryption` |
| [4005](4005.ps1) | Ensure account lockout duration is 15 minutes or more | `windows.lockout.duration` |
| [4006](4006.ps1) | Ensure account lockout threshold is between 1 and 5 attempts | `windows.lockout.threshold` |
| [4007](4007.ps1) | Ensure 'Act as part of the operating system' is assigned to No One | `windows.rights.act_as_os` |
| [4008](4008.ps1) | Ensure a logon legal notice title and text are configured | `windows.banner.legal_notice` |
| [4009](4009.ps1) | Ensure the Guest account is disabled | `windows.accounts.guest_disabled` |
| [4010](4010.ps1) | Ensure 'Application Group Management' auditing includes Success | `windows.audit.application_group_management` |
| [4011](4011.ps1) | Ensure 'Computer Account Management' auditing includes Success | `windows.audit.computer_account_management` |
| [4012](4012.ps1) | Ensure 'Distribution Group Management' auditing includes Success | `windows.audit.distribution_group_management` |
| [4013](4013.ps1) | Ensure 'Other Account Management Events' auditing includes Success | `windows.audit.other_account_management_events` |
| [4014](4014.ps1) | Ensure 'Security Group Management' auditing includes Success | `windows.audit.security_group_management` |
| [4015](4015.ps1) | Ensure 'Process Creation' auditing includes Success | `windows.audit.process_creation` |
| [4016](4016.ps1) | Ensure 'Directory Service Access' auditing includes Success | `windows.audit.directory_service_access` |
| [4017](4017.ps1) | Ensure 'Directory Service Changes' auditing includes Success | `windows.audit.directory_service_changes` |
| [4018](4018.ps1) | Ensure 'Account Lockout' auditing includes Success | `windows.audit.account_lockout` |
| [4019](4019.ps1) | Ensure 'Logoff' auditing includes Success | `windows.audit.logoff` |
| [4020](4020.ps1) | Ensure 'Other Logon/Logoff Events' auditing includes Success | `windows.audit.other_logon_logoff_events` |
| [4021](4021.ps1) | Ensure 'Special Logon' auditing includes Success | `windows.audit.special_logon` |
| [4022](4022.ps1) | Ensure 'Audit Policy Change' auditing includes Success | `windows.audit.audit_policy_change` |
| [4023](4023.ps1) | Ensure 'Authentication Policy Change' auditing includes Success | `windows.audit.authentication_policy_change` |
| [4024](4024.ps1) | Ensure 'Sensitive Privilege Use' auditing includes Success | `windows.audit.sensitive_privilege_use` |
| [4025](4025.ps1) | Ensure antivirus real-time protection is enabled | `windows.defender.realtime_protection` |
| [4026](4026.ps1) | Ensure a Windows Server Backup policy is configured | `windows.backup.policy` |
| [4037](4037.ps1) | Ensure the SMBv1 server protocol is disabled | `windows.network.smb1_disabled` |
| [4038](4038.ps1) | Ensure the SMB server requires message signing | `windows.network.smb_signing_required` |
| [4039](4039.ps1) | Ensure Remote Desktop requires Network Level Authentication | `windows.remote.rdp_nla_required` |
| [4040](4040.ps1) | Ensure Windows Firewall is enabled for all profiles | `windows.firewall.all_profiles_enabled` |
| [4041](4041.ps1) | Ensure User Account Control is enabled | `windows.uac.enabled` |
| [4042](4042.ps1) | Ensure UAC prompts administrators for consent on the secure desktop | `windows.uac.admin_consent_prompt` |
| [4043](4043.ps1) | Ensure LLMNR (multicast name resolution) is disabled | `windows.network.llmnr_disabled` |
| [4044](4044.ps1) | Ensure WDigest does not store plaintext credentials | `windows.credentials.wdigest_disabled` |
| [4045](4045.ps1) | Ensure LSA protection (RunAsPPL) is enabled | `windows.credentials.lsa_protection` |
| [4046](4046.ps1) | Ensure anonymous enumeration of accounts and shares is restricted | `windows.network.anonymous_enumeration_restricted` |
| [4047](4047.ps1) | Ensure LAN Manager authentication accepts NTLMv2 only | `windows.network.ntlmv2_only` |
| [4048](4048.ps1) | Ensure AutoPlay is turned off for all drives | `windows.hardening.autorun_disabled` |
| [4049](4049.ps1) | Ensure the Remote Registry service is disabled | `windows.services.remote_registry_disabled` |
| [4050](4050.ps1) | Ensure PowerShell script block logging is enabled | `windows.logging.powershell_script_block` |
| [4051](4051.ps1) | Ensure the Security event log is at least 196608 KB | `windows.logging.security_log_size` |
| [4052](4052.ps1) | Ensure BitLocker protects the operating system drive | `windows.encryption.bitlocker_os_drive` |
| [4053](4053.ps1) | Ensure the built-in Administrator account is renamed | `windows.accounts.administrator_renamed` |
| [4054](4054.ps1) | Ensure the machine inactivity limit is 900 seconds or less | `windows.session.inactivity_limit` |

### Inventory collectors (10)

Served by the Go binary: `checklist <id>`.

| ID | Collects | Key |
|---:|---|---|
| 4027 | SSH authorized_keys per user | `collect.ssh_keys` |
| 4028 | Local account names | `collect.accounts` |
| 4029 | Users, groups and sudoers/administrators membership | `collect.users_groups` |
| 4030 | Effective password policy | `collect.password_policy` |
| 4031 | OS, kernel and patch level | `collect.patching` |
| 4032 | SHA-256 checksums of the files given with --files | `collect.file_checksums` |
| 4033 | Files in the directories given with --folders | `collect.file_listing` |
| 4034 | Non-loopback listening TCP/UDP ports | `collect.listening_ports` |
| 4035 | Host firewall rules | `collect.firewall_rules` |
| 4036 | Logging configuration and agent status | `collect.log_config` |

<!-- END GENERATED -->
