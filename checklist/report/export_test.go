package report

import (
	"encoding/csv"
	"encoding/json"
	"encoding/xml"
	"strings"
	"testing"
	"time"

	"checklist/runner"
)

func sampleReport() *runner.Report {
	return &runner.Report{
		SchemaVersion: runner.SchemaVersion,
		Tool:          runner.Tool{Name: "checklist", Version: "test"},
		Platform:      runner.PlatformInfo{Key: "ubuntu", Name: "Ubuntu", Kind: "linux"},
		Host:          runner.Host{Hostname: "web01"},
		StartedAt:     time.Date(2026, 10, 27, 8, 0, 0, 0, time.UTC),
		FinishedAt:    time.Date(2026, 10, 27, 8, 0, 2, 0, time.UTC),
		DurationMS:    2000,
		Summary:       runner.Summary{Total: 4, Pass: 1, Fail: 1, Error: 1, Waived: 1, Score: 50},
		Checks: []runner.CheckResult{
			{Key: "linux.ssh.a", ID: "1075", Title: "Ensure A", Section: "ssh", Status: runner.StatusPass, DurationMS: 5},
			{Key: "linux.ssh.b", ID: "1076", Title: "Ensure B", Section: "ssh", Status: runner.StatusFail, Message: "B is off", Details: []string{"x=1"}, ExitCode: 1},
			{Key: "linux.auth.c", ID: "1085", Title: "Ensure C", Section: "auth", Status: runner.StatusError, Error: "timed out", ExitCode: -1},
			{Key: "linux.filesystem.d", ID: "1004", Title: "Ensure D", Section: "filesystem", Status: runner.StatusWaived, Message: "no /tmp",
				Waiver: &runner.Waiver{Reason: "single-partition cloud image", ApprovedBy: "secteam", Expires: "2027-06-30"}},
		},
	}
}

func TestSARIF(t *testing.T) {
	var b strings.Builder
	if err := WriteSARIF(&b, sampleReport()); err != nil {
		t.Fatal(err)
	}
	var doc struct {
		Version string
		Runs    []struct {
			Tool struct {
				Driver struct{ Rules []struct{ ID string } }
			}
			Results []struct {
				RuleID              string
				Level               string
				Message             struct{ Text string }
				PartialFingerprints map[string]string
				Suppressions        []struct{ Kind, Justification string }
				Locations           []struct {
					PhysicalLocation struct{ ArtifactLocation struct{ URI string } }
				}
			}
		}
	}
	if err := json.Unmarshal([]byte(b.String()), &doc); err != nil {
		t.Fatal(err)
	}
	run := doc.Runs[0]
	if doc.Version != "2.1.0" || len(run.Tool.Driver.Rules) != 4 || len(run.Results) != 3 {
		t.Fatalf("version %s, %d rules, %d results", doc.Version, len(run.Tool.Driver.Rules), len(run.Results))
	}
	fail, errored, waived := run.Results[0], run.Results[1], run.Results[2]
	if fail.RuleID != "linux.ssh.b" || fail.Level != "error" || fail.Message.Text != "Ensure B: B is off" ||
		fail.Locations[0].PhysicalLocation.ArtifactLocation.URI != "ubuntu/1076.sh" || fail.PartialFingerprints["secbaseline/v1"] == "" {
		t.Errorf("fail result = %+v", fail)
	}
	if errored.Level != "warning" {
		t.Errorf("error result level = %s", errored.Level)
	}
	if len(waived.Suppressions) != 1 || waived.Suppressions[0].Justification != "single-partition cloud image" {
		t.Errorf("waived result = %+v", waived)
	}
}

func TestSARIFScore(t *testing.T) {
	score := func(rep *runner.Report) (any, bool) {
		var b strings.Builder
		if err := WriteSARIF(&b, rep); err != nil {
			t.Fatal(err)
		}
		var doc struct {
			Runs []struct{ Properties map[string]any }
		}
		if err := json.Unmarshal([]byte(b.String()), &doc); err != nil {
			t.Fatal(err)
		}
		v, ok := doc.Runs[0].Properties["score"]
		return v, ok
	}
	if v, ok := score(sampleReport()); !ok || v != 50.0 {
		t.Errorf("score = %v, %v; want 50", v, ok)
	}
	rep := sampleReport()
	rep.Checks, rep.Summary = nil, runner.Summary{}
	if v, ok := score(rep); ok {
		t.Errorf("report without checks has score %v", v)
	}
}

func TestJUnit(t *testing.T) {
	var b strings.Builder
	if err := WriteJUnit(&b, sampleReport()); err != nil {
		t.Fatal(err)
	}
	var doc junitSuites
	if err := xml.Unmarshal([]byte(b.String()), &doc); err != nil {
		t.Fatal(err)
	}
	s := doc.Suites[0]
	if doc.Tests != 4 || s.Failures != 1 || s.Errors != 1 || s.Skipped != 1 || s.Name != "ubuntu web01" {
		t.Fatalf("suite = %+v", s)
	}
	if s.Cases[1].Failure == nil || s.Cases[1].Failure.Message != "B is off" || s.Cases[3].Skipped == nil {
		t.Errorf("cases = %+v", s.Cases)
	}
}

func TestCSV(t *testing.T) {
	var b strings.Builder
	if err := WriteCSV(&b, sampleReport()); err != nil {
		t.Fatal(err)
	}
	rows, err := csv.NewReader(strings.NewReader(b.String())).ReadAll()
	if err != nil {
		t.Fatal(err)
	}
	if len(rows) != 5 || rows[0][0] != "platform" || rows[4][6] != "waived" || rows[4][9] != "single-partition cloud image" {
		t.Fatalf("rows = %v", rows)
	}
}

func TestFormatFor(t *testing.T) {
	for path, want := range map[string]string{"a.sarif": "sarif", "a.xml": "junit", "a.CSV": "csv", "a.html": "html", "-": "html"} {
		if got := FormatFor(path); got != want {
			t.Errorf("FormatFor(%s) = %s, want %s", path, got, want)
		}
	}
}
