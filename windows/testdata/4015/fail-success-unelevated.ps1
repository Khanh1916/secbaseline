# 'Process Creation' audits Success, but without elevation the audit policy cannot be read.
Set-AuditPolicy 'Process Creation' -Success
