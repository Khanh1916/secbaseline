package runner

import (
	"math"
	"time"
)

// SchemaVersion is bumped whenever the JSON report layout changes incompatibly.
const SchemaVersion = 1

// Check and collector statuses.
const (
	StatusPass    = "pass"
	StatusFail    = "fail"
	StatusError   = "error"
	StatusOK      = "ok"
	StatusSkipped = "skipped"
	// StatusWaived is a failing check covered by an active waiver in the run's policy.
	StatusWaived = "waived"
)

type Report struct {
	SchemaVersion int               `json:"schema_version"`
	Tool          Tool              `json:"tool"`
	Platform      PlatformInfo      `json:"platform"`
	Host          Host              `json:"host"`
	Target        *Target           `json:"target,omitempty"`
	StartedAt     time.Time         `json:"started_at"`
	FinishedAt    time.Time         `json:"finished_at"`
	DurationMS    int64             `json:"duration_ms"`
	Summary       Summary           `json:"summary"`
	Checks        []CheckResult     `json:"checks"`
	Collectors    []CollectorResult `json:"collectors,omitempty"`
	Policy        *PolicyInfo       `json:"policy,omitempty"`
}

// PolicyInfo records the policy a run used and the waivers that need attention.
type PolicyInfo struct {
	Name        string `json:"name"`
	Description string `json:"description,omitempty"`
	// Excluded counts controls left out by the policy's include/exclude lists.
	Excluded int `json:"excluded"`
	// ExpiredWaivers no longer apply; their checks count as failures again.
	ExpiredWaivers []WaiverNote `json:"expired_waivers,omitempty"`
	// UnusedWaivers cover checks that now pass, so the exception can be removed.
	UnusedWaivers []WaiverNote `json:"unused_waivers,omitempty"`
}

type WaiverNote struct {
	Key     string `json:"key"`
	ID      string `json:"id"`
	Title   string `json:"title"`
	Reason  string `json:"reason"`
	Expires string `json:"expires"`
}

// Subject is what the report is about: the device hostname for network audits,
// the host name otherwise.
func (r *Report) Subject() string {
	if r.Target != nil && r.Target.DeviceHostname != "" {
		return r.Target.DeviceHostname
	}
	return r.Host.Hostname
}

type Tool struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

type PlatformInfo struct {
	Key  string `json:"key"`
	Name string `json:"name"`
	Kind string `json:"kind"`
}

// Host describes the machine the runner executed on.
type Host struct {
	Hostname        string `json:"hostname"`
	OS              string `json:"os"`
	Platform        string `json:"platform,omitempty"`
	PlatformVersion string `json:"platform_version,omitempty"`
	KernelVersion   string `json:"kernel_version,omitempty"`
	Arch            string `json:"arch"`
}

// Target describes the device configuration audited by a network run.
type Target struct {
	ConfigFile     string `json:"config_file"`
	SHA256         string `json:"sha256"`
	DeviceHostname string `json:"device_hostname,omitempty"`
}

type Summary struct {
	Total int `json:"total"`
	Pass  int `json:"pass"`
	Fail  int `json:"fail"`
	Error int `json:"error"`
	// Waived counts failing checks covered by a waiver; like errors they are excluded from the score.
	Waived int `json:"waived"`
	// Score is pass / (pass + fail) as a percentage; errors and waived checks are excluded.
	// It is 0 when no check passed or failed; see HasScore.
	Score float64 `json:"score"`
}

// HasScore reports whether any check passed or failed. A report with only
// collectors, errors or waived checks has no score, rather than a score of 0.
func (s Summary) HasScore() bool { return s.Pass+s.Fail > 0 }

type CheckResult struct {
	Key        string   `json:"key"`
	ID         string   `json:"id"`
	Title      string   `json:"title"`
	Section    string   `json:"section"`
	Status     string   `json:"status"`
	Message    string   `json:"message,omitempty"`
	Details    []string `json:"details,omitempty"`
	ExitCode   int      `json:"exit_code"`
	DurationMS int64    `json:"duration_ms"`
	Error      string   `json:"error,omitempty"`
	Output     string   `json:"output,omitempty"`
	Stderr     string   `json:"stderr,omitempty"`
	Waiver     *Waiver  `json:"waiver,omitempty"`
}

// Waiver records the accepted exception that turned a failing check into StatusWaived.
type Waiver struct {
	Reason     string `json:"reason"`
	ApprovedBy string `json:"approved_by,omitempty"`
	Expires    string `json:"expires,omitempty"`
	Ticket     string `json:"ticket,omitempty"`
}

type CollectorResult struct {
	Key        string `json:"key"`
	ID         string `json:"id"`
	Title      string `json:"title"`
	Status     string `json:"status"`
	Output     string `json:"output,omitempty"`
	Error      string `json:"error,omitempty"`
	DurationMS int64  `json:"duration_ms"`
}

func summarize(checks []CheckResult) Summary {
	s := Summary{Total: len(checks)}
	for _, c := range checks {
		switch c.Status {
		case StatusPass:
			s.Pass++
		case StatusFail:
			s.Fail++
		case StatusWaived:
			s.Waived++
		default:
			s.Error++
		}
	}
	if s.Pass+s.Fail > 0 {
		s.Score = math.Round(float64(s.Pass)*1000/float64(s.Pass+s.Fail)) / 10
	}
	return s
}
