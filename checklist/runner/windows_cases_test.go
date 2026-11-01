package runner

import (
	"context"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"slices"
	"strconv"
	"strings"
	"testing"
	"time"

	"checklist/catalog"
)

// Windows host checks are tested on the machine that runs the test. A case is
// a setup script, windows/testdata/<id>/pass-<case>.ps1 or fail-<case>.ps1,
// that puts this machine's security settings (registry values, local security
// policy, audit policy, services, firewall profiles, local accounts) into a
// compliant or a non-compliant state; the check must then give the verdict
// the file name starts with. Setup scripts run elevated inside
// checklist/runner/testdata/windows-setup.ps1, whose helpers record every
// setting before they change it; that state is restored after the check, so
// that cases do not leak into each other. A setup that exits 77 skips its case
// (for example a feature this edition of Windows does not have).
//
// The test runs elevated, as the checks are meant to. A case whose name ends
// in -unelevated runs its check as LOCAL SERVICE instead, an account without
// administrator rights, for the checks that fall back to other sources or
// must fail with a reason without elevation.
//
// The cases change the security settings of the machine they run on, so they
// only run where CHECKLIST_CASES_WINDOWS=1 is set: in CI, on a disposable
// GitHub runner. Never set it on a machine you want to keep.

// TestWindowsCases runs every Windows case, one at a time, on this machine:
//
//	CHECKLIST_CASES_WINDOWS=1 go test -count=1 -timeout 60m -run TestWindowsCases ./runner
//
// It needs an elevated session. -run TestWindowsCases/<key> selects cases.
func TestWindowsCases(t *testing.T) {
	if os.Getenv("CHECKLIST_CASES_WINDOWS") != "1" {
		t.Skip("set CHECKLIST_CASES_WINDOWS=1 to run the Windows cases; they change this machine's security settings")
	}
	if runtime.GOOS != "windows" {
		t.Fatal("the Windows cases run on Windows")
	}
	cat := loadCatalog(t)
	cases, err := hostCases(cat, "windows")
	if err != nil {
		t.Fatal(err)
	}
	setup, err := filepath.Abs(filepath.Join("testdata", "windows-setup.ps1"))
	if err != nil {
		t.Fatal(err)
	}

	keys := make([]string, 0, len(cases))
	for k := range cases {
		keys = append(keys, k)
	}
	slices.Sort(keys)
	// After a failed restore the machine is in an unknown state, so the
	// verdicts of later cases would mean nothing.
	var unrestored string
	for _, key := range keys {
		for _, c := range cases[key] {
			if unrestored != "" {
				t.Fatalf("stopped: the settings changed by %s could not be restored", unrestored)
			}
			name := key + "/" + strings.TrimSuffix(filepath.Base(c.path), ".ps1")
			t.Run(name, func(t *testing.T) {
				undo := filepath.Join(t.TempDir(), "undo.xml")
				// Cleanups run last first: the state is restored before the
				// temporary directory with the undo file is removed.
				t.Cleanup(func() {
					if out, err := windowsSetup(setup, "-Undo", undo, "-Restore"); err != nil {
						unrestored = c.path
						t.Errorf("%s: restoring the settings: %v\n%s", c.path, err, lastLines(out, 40))
					}
				})
				out, err := windowsSetup(setup, "-Undo", undo, "-Case", filepath.Join(cat.Root, c.path))
				var exitErr *exec.ExitError
				switch {
				case errors.As(err, &exitErr) && exitErr.ExitCode() == 77:
					t.Skipf("setup skipped the case: %s", lastLines(out, 3))
				case err != nil:
					t.Fatalf("%s: %v\n%s", c.path, err, lastLines(out, 40))
				}
				if strings.HasSuffix(name, "-unelevated") {
					checkVerdict(t, "windows", c, runUnelevated(t, setup, undo, cat, c))
					return
				}
				rep, err := Run(context.Background(), cat, Options{
					Platform: "windows",
					Only:     []string{c.key},
					Jobs:     1,
					Timeout:  2 * time.Minute,
				})
				if err != nil {
					t.Fatal(err)
				}
				checkVerdict(t, "windows", c, rep)
			})
		}
	}
}

// runUnelevated runs the check of a case as LOCAL SERVICE, an account without
// administrator rights, and reads its output as Run does.
func runUnelevated(t *testing.T, setup, undo string, cat *catalog.Catalog, c caseFile) *Report {
	t.Helper()
	id, err := strconv.Atoi(c.id)
	if err != nil {
		t.Fatal(err)
	}
	out, err := windowsSetup(setup, "-Undo", undo, "-Unelevated", cat.ScriptPath("windows", id))
	code := 0
	var exitErr *exec.ExitError
	switch {
	case errors.As(err, &exitErr) && exitErr.ExitCode() == 2:
		t.Fatalf("%s: %s", c.path, lastLines(out, 40))
	case errors.As(err, &exitErr):
		code = exitErr.ExitCode()
	case err != nil:
		t.Fatalf("%s: %v", c.path, err)
	}
	p := parseOutput(out)
	r := CheckResult{Key: c.key, ID: c.id, ExitCode: code, Message: p.message, Details: p.details}
	r.Status, r.Error = classify(p, code)
	return &Report{Checks: []CheckResult{r}}
}

// windowsSetup runs windows-setup.ps1 with the given arguments.
func windowsSetup(script string, args ...string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Minute)
	defer cancel()
	args = append([]string{"-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", script}, args...)
	out, err := exec.CommandContext(ctx, "powershell", args...).CombinedOutput()
	return string(out), err
}
