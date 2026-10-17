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
		Summary:    runner.Summary{Score: score},
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
