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
	// Score is pass / (pass + fail) as a percentage; errors are excluded.
	Score float64 `json:"score"`
}

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
		default:
			s.Error++
		}
	}
	if s.Pass+s.Fail > 0 {
		s.Score = math.Round(float64(s.Pass)*1000/float64(s.Pass+s.Fail)) / 10
	}
	return s
}
