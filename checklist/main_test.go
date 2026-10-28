package main

import (
	"testing"

	"checklist/runner"
)

func TestSummaryLine(t *testing.T) {
	tests := []struct {
		rep  runner.Report
		want string
	}{
		{runner.Report{Platform: runner.PlatformInfo{Key: "ubuntu"}, Summary: runner.Summary{Total: 3, Pass: 1, Fail: 1, Waived: 1, Score: 50}},
			"ubuntu: 3 checks, 1 passed, 1 failed, 1 waived, 0 errors (score 50.0%)"},
		{runner.Report{Platform: runner.PlatformInfo{Key: "windows"}, Collectors: []runner.CollectorResult{{Key: "collect.listening_ports"}}},
			"windows: 0 checks, 0 passed, 0 failed, 0 errors, 1 collectors (no score: no check passed or failed)"},
		{runner.Report{Platform: runner.PlatformInfo{Key: "iosxe"}, Summary: runner.Summary{Total: 1, Fail: 1}},
			"iosxe: 1 checks, 0 passed, 1 failed, 0 errors (score 0.0%)"},
	}
	for _, tt := range tests {
		if got := summaryLine(&tt.rep); got != tt.want {
			t.Errorf("summaryLine = %q, want %q", got, tt.want)
		}
	}
}
