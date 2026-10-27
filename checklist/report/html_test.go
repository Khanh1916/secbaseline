package report

import (
	"strings"
	"testing"
	"time"

	"checklist/runner"
)

func TestWriteHTML(t *testing.T) {
	rep := &runner.Report{
		SchemaVersion: runner.SchemaVersion,
		Tool:          runner.Tool{Name: "checklist", Version: "test"},
		Platform:      runner.PlatformInfo{Key: "iosxe", Name: "Cisco IOS XE", Kind: "network"},
		Target:        &runner.Target{ConfigFile: "/tmp/r1.cfg", SHA256: "abc", DeviceHostname: "r1"},
		StartedAt:     time.Unix(0, 0),
		Summary:       runner.Summary{Total: 2, Pass: 1, Fail: 1, Score: 50},
		Checks: []runner.CheckResult{
			{Key: "network.hostname", ID: "7001", Title: "Ensure a non-default hostname is configured", Section: "network", Status: runner.StatusPass},
			{Key: "network.ssh", ID: "7011", Title: "Ensure <SSH> v2", Section: "network", Status: runner.StatusFail, Details: []string{"telnet enabled"}},
		},
	}
	var b strings.Builder
	if err := WriteHTML(&b, rep); err != nil {
		t.Fatal(err)
	}
	html := b.String()
	for _, want := range []string{"Cisco IOS XE · r1", "7011", "telnet enabled", "Ensure &lt;SSH&gt; v2", "50%"} {
		if !strings.Contains(html, want) {
			t.Errorf("HTML missing %q", want)
		}
	}
}

func TestWriteHTMLWithoutScore(t *testing.T) {
	rep := &runner.Report{
		SchemaVersion: runner.SchemaVersion,
		Platform:      runner.PlatformInfo{Key: "ubuntu", Name: "Ubuntu", Kind: "linux"},
		Host:          runner.Host{Hostname: "web01"},
		StartedAt:     time.Unix(0, 0),
		Collectors:    []runner.CollectorResult{{Key: "collect.listening_ports", Title: "Ports", Status: runner.StatusOK, Output: "0.0.0.0:22/TCP"}},
	}
	var b strings.Builder
	if err := WriteHTML(&b, rep); err != nil {
		t.Fatal(err)
	}
	html := b.String()
	if !strings.Contains(html, "<strong>n/a</strong>") || strings.Contains(html, "0%</strong>") || strings.Contains(html, "conic-gradient") {
		t.Errorf("report without checks shows a score:\n%s", html)
	}
}
