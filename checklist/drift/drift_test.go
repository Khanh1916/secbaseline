package drift

import (
	"slices"
	"strings"
	"testing"

	"checklist/runner"
)

func rep(score float64, checks []runner.CheckResult, inv ...runner.CollectorResult) *runner.Report {
	return &runner.Report{
		Platform:   runner.PlatformInfo{Key: "ubuntu"},
		Host:       runner.Host{Hostname: "web01"},
		Summary:    runner.Summary{Pass: 1, Score: score}, // a passing check gives the report a score
		Checks:     checks,
		Collectors: inv,
	}
}

func TestCompare(t *testing.T) {
	old := rep(66.7, []runner.CheckResult{
		{Key: "a", Status: "pass"}, {Key: "b", Status: "fail"}, {Key: "c", Status: "pass"}, {Key: "gone", Status: "pass"},
	}, runner.CollectorResult{Key: "collect.listening_ports", Status: "ok", Output: "0.0.0.0:22/TCP\n0.0.0.0:80/TCP"})
	cur := rep(50, []runner.CheckResult{
		{Key: "a", Status: "fail", Message: "now failing"}, {Key: "b", Status: "pass"}, {Key: "c", Status: "error"}, {Key: "new", Status: "pass"},
	}, runner.CollectorResult{Key: "collect.listening_ports", Status: "ok", Output: "0.0.0.0:22/TCP\n0.0.0.0:4444/TCP"})

	r := Compare(old, cur)
	keys := func(cs []CheckChange) []string {
		var k []string
		for _, c := range cs {
			k = append(k, c.Key)
		}
		return k
	}
	if got := keys(r.Regressions); !slices.Equal(got, []string{"a"}) {
		t.Errorf("regressions = %v", got)
	}
	if got := keys(r.Fixed); !slices.Equal(got, []string{"b"}) {
		t.Errorf("fixed = %v", got)
	}
	if got := keys(r.Changed); !slices.Equal(got, []string{"c", "new", "gone"}) {
		t.Errorf("changed = %v", got)
	}
	if len(r.Inventory) != 1 || !slices.Equal(r.Inventory[0].Added, []string{"0.0.0.0:4444/TCP"}) || !slices.Equal(r.Inventory[0].Removed, []string{"0.0.0.0:80/TCP"}) {
		t.Errorf("inventory = %+v", r.Inventory)
	}
	if r.ScoreDelta != -16.7 || !r.HasDrift() {
		t.Errorf("delta = %v, drift = %v", r.ScoreDelta, r.HasDrift())
	}

	var b strings.Builder
	WriteText(&b, r)
	for _, want := range []string{"Regressions (1)", "now failing", "+ 0.0.0.0:4444/TCP", "- 0.0.0.0:80/TCP", "(-16.7)"} {
		if !strings.Contains(b.String(), want) {
			t.Errorf("text missing %q:\n%s", want, b.String())
		}
	}
}

func TestNoDrift(t *testing.T) {
	a := rep(100, []runner.CheckResult{{Key: "a", Status: "pass"}})
	if r := Compare(a, a); r.HasDrift() || len(r.Fixed) != 0 {
		t.Fatalf("unexpected drift: %+v", r)
	}
}

func TestCompareWithoutScore(t *testing.T) {
	scored := rep(80, []runner.CheckResult{{Key: "a", Status: "pass"}})
	inventory := &runner.Report{Platform: runner.PlatformInfo{Key: "ubuntu"}, Host: runner.Host{Hostname: "web01"},
		Collectors: []runner.CollectorResult{{Key: "collect.listening_ports", Status: "ok", Output: "0.0.0.0:22/TCP"}}}
	r := Compare(scored, inventory)
	if r.HasDelta() || r.ScoreDelta != 0 || r.New.HasScore || !r.Old.HasScore {
		t.Errorf("delta = %v, has delta = %v, old %+v, new %+v", r.ScoreDelta, r.HasDelta(), r.Old, r.New)
	}
	var b strings.Builder
	WriteText(&b, r)
	if !strings.Contains(b.String(), "Score: 80.0% -> n/a\n") {
		t.Errorf("text:\n%s", b.String())
	}
}

func TestCompareAcrossSelections(t *testing.T) {
	ports := runner.CollectorResult{Key: "collect.listening_ports", Status: "ok", Output: "0.0.0.0:22/TCP"}
	full := rep(66.7, []runner.CheckResult{
		{Key: "linux.ssh.root", Status: "pass"}, {Key: "linux.ssh.gone", Status: "pass"}, {Key: "linux.auth.pw", Status: "fail"},
	}, ports)
	subset := rep(100, []runner.CheckResult{{Key: "linux.ssh.root", Status: "pass"}, {Key: "linux.ssh.new", Status: "pass"}})
	subset.Only = []string{"linux.ssh"}
	collect := rep(0, nil, ports)
	collect.Summary, collect.Only = runner.Summary{}, []string{"collect."}
	profile := rep(100, []runner.CheckResult{{Key: "linux.ssh.root", Status: "pass"}, {Key: "linux.ssh.gone", Status: "pass"}})
	profile.Policy = &runner.PolicyInfo{Name: "web", Exclude: []string{"linux.auth"}, Excluded: 1}

	for _, tc := range []struct {
		name     string
		old, cur *runner.Report
		changed  []string // keys under Changed
		notRun   int
		text     string
	}{
		// linux.auth.pw was not run; linux.ssh.gone was in scope and is gone, linux.ssh.new is new.
		{"subset after full", full, subset, []string{"linux.ssh.new", "linux.ssh.gone"}, 1, "1 check not compared"},
		{"full after subset", subset, full, []string{"linux.ssh.gone", "linux.ssh.new"}, 1, "1 check not compared"},
		{"collector-only after full", full, collect, nil, 3, "No changes.\n\n3 checks not compared"},
		{"full after collector-only", collect, full, nil, 3, "3 checks not compared"},
		{"policy profile after full", full, profile, nil, 1, "No changes."},
		// A report without a recorded selection ran everything, so a missing check is a change.
		{"unrecorded selection", subset, rep(100, []runner.CheckResult{{Key: "linux.ssh.root", Status: "pass"}}), []string{"linux.ssh.new"}, 0, "absent"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			r := Compare(tc.old, tc.cur)
			var changed []string
			for _, c := range r.Changed {
				changed = append(changed, c.Key)
			}
			if !slices.Equal(changed, tc.changed) || r.NotRun != tc.notRun || len(r.Regressions)+len(r.Fixed)+len(r.Inventory) != 0 {
				t.Errorf("changed = %v, not run = %d, result %+v", changed, r.NotRun, r)
			}
			if r.HasDrift() != (len(tc.changed) > 0) {
				t.Errorf("drift = %v", r.HasDrift())
			}
			var b strings.Builder
			WriteText(&b, r)
			if !strings.Contains(b.String(), tc.text) || (tc.notRun == 0) != !strings.Contains(b.String(), "not compared") {
				t.Errorf("text missing %q:\n%s", tc.text, b.String())
			}
		})
	}
}
