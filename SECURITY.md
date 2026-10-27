# Security policy

## Supported versions

Security fixes are made on `master` and shipped in the next release. Only the latest release is
supported.

## Reporting a vulnerability

Please do not open a public issue for security problems.

Report privately through GitHub: open the repository's **Security** tab and choose
**Report a vulnerability**. Include the affected version or commit, how to reproduce the problem,
and its impact.

You can expect an acknowledgement within 7 days. Once a fix is available, it is released and the
advisory is published with credit to the reporter unless you prefer otherwise.

## Verifying releases

Release archives and container images are built by GitHub Actions from a tagged commit and carry
build provenance attestations; see "Verifying downloads" in the README.

## Scope

In scope:

- The `checklist` binary, including the dashboard (`checklist serve`): authentication bypass,
  path traversal, injection, or exposure of stored reports.
- Check scripts that could modify the system they inspect or execute untrusted input.
- A check that reports `PASS` for a configuration it is meant to fail, when that hides a real
  weakness.

The checks are read-only by design. Reports describe a host's security posture, so treat them and
the dashboard's data directory as sensitive.
