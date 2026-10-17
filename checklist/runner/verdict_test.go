package runner

import (
	"slices"
	"testing"
)

func TestParseOutput(t *testing.T) {
	p := parseOutput("INFO: File: /etc/pam.d/sshd\nINFO: deny=5\nPASS: Account lockout (deny) is configured in PAM\n")
	if p.verdict != "PASS" || p.message != "Account lockout (deny) is configured in PAM" {
		t.Fatalf("verdict = %q %q", p.verdict, p.message)
	}
	if want := []string{"File: /etc/pam.d/sshd", "deny=5"}; !slices.Equal(p.details, want) {
		t.Fatalf("details = %q, want %q", p.details, want)
	}
}

func TestParseOutputNetworkAndCRLF(t *testing.T) {
	if p := parseOutput("FAIL\r\n"); p.verdict != "FAIL" || p.message != "" {
		t.Fatalf("got %+v", p)
	}
}

func TestParseOutputKeepsUnknownLines(t *testing.T) {
	p := parseOutput("some tool noise\nFAIL: x\n")
	if p.verdict != "FAIL" || !slices.Equal(p.extra, []string{"some tool noise"}) {
		t.Fatalf("got %+v", p)
	}
}

func TestClassify(t *testing.T) {
	tests := []struct {
		out    string
		exit   int
		status string
	}{
		{"PASS: ok", 0, StatusPass},
		{"FAIL: bad", 1, StatusFail},
		{"PASS", 0, StatusPass},
		{"FAIL: bad", 0, StatusError}, // exit code disagrees with verdict
		{"PASS: ok", 1, StatusError},
		{"no verdict here", 0, StatusError},
		{"FAIL: bad", 2, StatusError},
	}
	for _, tt := range tests {
		if got, _ := classify(parseOutput(tt.out), tt.exit); got != tt.status {
			t.Errorf("classify(%q, %d) = %s, want %s", tt.out, tt.exit, got, tt.status)
		}
	}
}

func TestSummarize(t *testing.T) {
	s := summarize([]CheckResult{{Status: StatusPass}, {Status: StatusPass}, {Status: StatusFail}, {Status: StatusError}})
	if s.Total != 4 || s.Pass != 2 || s.Fail != 1 || s.Error != 1 || s.Score != 66.7 {
		t.Fatalf("summary = %+v", s)
	}
}
