# Windows checks

Security baseline checks for Microsoft Windows, IDs `4001–4026`. Inventory collectors `4027–4036`
are served by the Go binary (`checklist <id>`), not by scripts here.

Each PowerShell script runs on the target host with no arguments, prints exactly one
`PASS: <reason>` or `FAIL: <reason>` line, and exits `0` (pass) or `1` (fail).

## Usage

Run from an **elevated** PowerShell prompt: `secedit`, `auditpol` and parts of `net accounts` need
Administrator rights, and without them the affected checks report `FAIL`.

```powershell
.\checklist\checklist.exe run --html windows-report.html -o windows-report.json
```

Run one check:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File windows\4001.ps1; "exit=$LASTEXITCODE"
```

## Notes

- Password and lockout checks parse `net accounts`, whose labels are localized. They expect an English-language Windows.
- `4007.ps1` exports the local security policy with `secedit` to a temporary file and deletes it afterwards.
- `4026.ps1` uses `Get-WBPolicy`, which exists only where Windows Server Backup is installed.

<!-- BEGIN GENERATED: checklist docs -->

### Controls (26)

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
