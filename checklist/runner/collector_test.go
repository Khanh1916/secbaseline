package runner

import (
	"context"
	"path/filepath"
	"slices"
	"strings"
	"testing"
	"time"

	"checklist/catalog"
	"checklist/collector"
	"checklist/policy"
)

// runFakeCollector runs the patching collector on ubuntu with fn in place of
// the real collector.
func runFakeCollector(t *testing.T, timeout time.Duration, fn func(string, collector.Input) (string, error)) CollectorResult {
	t.Helper()
	cat, err := catalog.Load(filepath.Join("..", ".."))
	if err != nil {
		t.Fatal(err)
	}
	collect = fn
	t.Cleanup(func() { collect = collector.Run })

	rep, err := Run(context.Background(), cat, Options{
		Platform: "ubuntu", Only: []string{"collect.patching"}, Collectors: true, Timeout: timeout,
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(rep.Collectors) != 1 {
		t.Fatalf("ran %d collectors, want 1", len(rep.Collectors))
	}
	return rep.Collectors[0]
}

func TestCollectorTimeout(t *testing.T) {
	release := make(chan struct{})
	defer close(release)

	start := time.Now()
	r := runFakeCollector(t, 50*time.Millisecond, func(string, collector.Input) (string, error) {
		<-release
		return "late", nil
	})
	if elapsed := time.Since(start); elapsed > 5*time.Second {
		t.Errorf("run waited %s for a stuck collector", elapsed)
	}
	if r.Status != StatusError || r.Error != "timed out after 50ms" || r.Output != "" {
		t.Errorf("got status %q, error %q, output %q", r.Status, r.Error, r.Output)
	}
}

func TestCollectorPanic(t *testing.T) {
	r := runFakeCollector(t, time.Minute, func(string, collector.Input) (string, error) {
		panic("boom")
	})
	if r.Status != StatusError || !strings.Contains(r.Error, "collector panicked: boom") {
		t.Errorf("got status %q, error %q", r.Status, r.Error)
	}
}

func TestCollectorOutput(t *testing.T) {
	r := runFakeCollector(t, time.Minute, func(id string, _ collector.Input) (string, error) {
		return "id " + id + "\n", nil
	})
	if r.Status != StatusOK || r.Output != "id 1095" || r.ID != "1095" {
		t.Errorf("got status %q, id %q, output %q", r.Status, r.ID, r.Output)
	}
}

func TestRunRecordsSelection(t *testing.T) {
	cat, err := catalog.Load(filepath.Join("..", ".."))
	if err != nil {
		t.Fatal(err)
	}
	collect = func(string, collector.Input) (string, error) { return "", nil }
	t.Cleanup(func() { collect = collector.Run })
	only := []string{"collect.patching"}
	rep, err := Run(context.Background(), cat, Options{
		Platform: "ubuntu", Only: only, Collectors: true, Timeout: time.Minute,
		Policy: &policy.Policy{Name: "web", Include: []string{"linux.ssh"}, Exclude: []string{"linux.ssh.root"}},
	})
	if err != nil {
		t.Fatal(err)
	}
	only[0] = "changed by the caller"
	if !slices.Equal(rep.Only, []string{"collect.patching"}) || !slices.Equal(rep.Policy.Include, []string{"linux.ssh"}) ||
		!slices.Equal(rep.Policy.Exclude, []string{"linux.ssh.root"}) {
		t.Fatalf("only = %v, policy = %+v", rep.Only, rep.Policy)
	}

	if rep.Selects("linux.ssh.ciphers") {
		t.Error("a control outside --only was selected")
	}
	rep.Only = []string{"linux"}
	for key, want := range map[string]bool{"linux.ssh.ciphers": true, "linux.ssh.root": false, "linux.auth.x": false} {
		if got := rep.Selects(key); got != want {
			t.Errorf("with --only linux: Selects(%q) = %v", key, got)
		}
	}
	if !(&Report{}).Selects("linux.auth.x") {
		t.Error("a report without a selection must select every key")
	}
}
