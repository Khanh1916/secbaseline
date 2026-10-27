package report

import (
	"crypto/sha256"
	"encoding/csv"
	"encoding/hex"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"checklist/runner"
)

// Writer renders a report in one output format.
type Writer func(io.Writer, *runner.Report) error

// Formats lists every output format by name.
var Formats = map[string]Writer{
	"html":  WriteHTML,
	"sarif": WriteSARIF,
	"junit": WriteJUnit,
	"csv":   WriteCSV,
}

// FormatFor picks a format from a file name: .sarif, .xml (JUnit), .csv, otherwise HTML.
func FormatFor(path string) string {
	switch strings.ToLower(filepath.Ext(path)) {
	case ".sarif":
		return "sarif"
	case ".xml":
		return "junit"
	case ".csv":
		return "csv"
	}
	return "html"
}

const repoURL = "https://github.com/Khanh1916/secbaseline"

func scriptPath(rep *runner.Report, id string) string {
	ext := ".sh"
	if rep.Platform.Kind == "windows" {
		ext = ".ps1"
	}
	return rep.Platform.Key + "/" + id + ext
}

// --- SARIF 2.1.0 -----------------------------------------------------------

type sarifLog struct {
	Schema  string     `json:"$schema"`
	Version string     `json:"version"`
	Runs    []sarifRun `json:"runs"`
}

type sarifRun struct {
	Tool        sarifTool         `json:"tool"`
	Automation  map[string]string `json:"automationDetails"`
	Invocations []map[string]any  `json:"invocations"`
	Results     []sarifResult     `json:"results"`
	Properties  map[string]any    `json:"properties"`
}

type sarifTool struct {
	Driver sarifDriver `json:"driver"`
}

type sarifDriver struct {
	Name           string      `json:"name"`
	Version        string      `json:"version,omitempty"`
	InformationURI string      `json:"informationUri"`
	Rules          []sarifRule `json:"rules"`
}

type sarifText struct {
	Text string `json:"text"`
}

type sarifRule struct {
	ID               string         `json:"id"`
	ShortDescription sarifText      `json:"shortDescription"`
	HelpURI          string         `json:"helpUri"`
	Properties       map[string]any `json:"properties"`
}

type sarifResult struct {
	RuleID              string             `json:"ruleId"`
	RuleIndex           int                `json:"ruleIndex"`
	Level               string             `json:"level"`
	Message             sarifText          `json:"message"`
	Locations           []map[string]any   `json:"locations"`
	PartialFingerprints map[string]string  `json:"partialFingerprints"`
	Suppressions        []sarifSuppression `json:"suppressions,omitempty"`
	Properties          map[string]any     `json:"properties"`
}

type sarifSuppression struct {
	Kind          string `json:"kind"`
	Justification string `json:"justification,omitempty"`
}

// WriteSARIF reports failing, waived and errored checks as SARIF results, one rule
// per control. Passing checks produce no result. Locations point at the check
// script in this repository, so code scanning links each alert to its check.
func WriteSARIF(w io.Writer, rep *runner.Report) error {
	subject := rep.Subject()
	run := sarifRun{
		Tool: sarifTool{Driver: sarifDriver{Name: "secbaseline", Version: rep.Tool.Version, InformationURI: repoURL}},
		// One category per platform and subject, so uploads for different hosts do not replace each other.
		Automation: map[string]string{"id": "secbaseline/" + rep.Platform.Key + "/" + subject + "/"},
		Invocations: []map[string]any{{
			"executionSuccessful": true,
			"startTimeUtc":        rep.StartedAt.UTC().Format(time.RFC3339),
			"endTimeUtc":          rep.FinishedAt.UTC().Format(time.RFC3339),
		}},
		Results:    []sarifResult{},
		Properties: map[string]any{"platform": rep.Platform.Key, "subject": subject, "score": rep.Summary.Score},
	}
	for i, c := range rep.Checks {
		path := scriptPath(rep, c.ID)
		run.Tool.Driver.Rules = append(run.Tool.Driver.Rules, sarifRule{
			ID:               c.Key,
			ShortDescription: sarifText{c.Title},
			HelpURI:          repoURL + "/blob/master/" + path,
			Properties:       map[string]any{"tags": []string{"security", c.Section, rep.Platform.Kind}},
		})
		level := ""
		switch c.Status {
		case runner.StatusFail, runner.StatusWaived:
			level = "error"
		case runner.StatusError:
			level = "warning"
		default:
			continue
		}
		msg := c.Title
		if detail := firstNonEmpty(c.Message, c.Error); detail != "" {
			msg += ": " + detail
		}
		sum := sha256.Sum256([]byte(rep.Platform.Key + "|" + subject + "|" + c.Key))
		res := sarifResult{
			RuleID: c.Key, RuleIndex: i, Level: level, Message: sarifText{msg},
			Locations: []map[string]any{{
				"physicalLocation": map[string]any{"artifactLocation": map[string]string{"uri": path}},
				"logicalLocations": []map[string]string{{"name": subject, "kind": "host"}},
			}},
			PartialFingerprints: map[string]string{"secbaseline/v1": hex.EncodeToString(sum[:16])},
			Properties:          map[string]any{"status": c.Status, "subject": subject, "check_id": c.ID},
		}
		if c.Waiver != nil {
			res.Suppressions = []sarifSuppression{{Kind: "external", Justification: c.Waiver.Reason}}
		}
		run.Results = append(run.Results, res)
	}
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(sarifLog{Schema: "https://json.schemastore.org/sarif-2.1.0.json", Version: "2.1.0", Runs: []sarifRun{run}})
}

// --- JUnit XML -------------------------------------------------------------

type junitSuites struct {
	XMLName  xml.Name     `xml:"testsuites"`
	Name     string       `xml:"name,attr"`
	Tests    int          `xml:"tests,attr"`
	Failures int          `xml:"failures,attr"`
	Errors   int          `xml:"errors,attr"`
	Skipped  int          `xml:"skipped,attr"`
	Time     string       `xml:"time,attr"`
	Suites   []junitSuite `xml:"testsuite"`
}

type junitSuite struct {
	Name      string      `xml:"name,attr"`
	Tests     int         `xml:"tests,attr"`
	Failures  int         `xml:"failures,attr"`
	Errors    int         `xml:"errors,attr"`
	Skipped   int         `xml:"skipped,attr"`
	Time      string      `xml:"time,attr"`
	Timestamp string      `xml:"timestamp,attr"`
	Hostname  string      `xml:"hostname,attr"`
	Cases     []junitCase `xml:"testcase"`
}

type junitCase struct {
	Classname string        `xml:"classname,attr"`
	Name      string        `xml:"name,attr"`
	Time      string        `xml:"time,attr"`
	Failure   *junitMessage `xml:"failure,omitempty"`
	Error     *junitMessage `xml:"error,omitempty"`
	Skipped   *junitMessage `xml:"skipped,omitempty"`
}

type junitMessage struct {
	Message string `xml:"message,attr"`
	Text    string `xml:",chardata"`
}

func seconds(ms int64) string { return strconv.FormatFloat(float64(ms)/1000, 'f', 3, 64) }

// WriteJUnit writes one test suite with one test case per check: fail is a
// failure, error is an error, waived is skipped.
func WriteJUnit(w io.Writer, rep *runner.Report) error {
	subject := rep.Subject()
	suite := junitSuite{
		Name: rep.Platform.Key + " " + subject, Hostname: subject,
		Timestamp: rep.StartedAt.UTC().Format("2006-01-02T15:04:05"), Time: seconds(rep.DurationMS),
	}
	for _, c := range rep.Checks {
		tc := junitCase{Classname: "secbaseline." + rep.Platform.Key + "." + c.Section, Name: c.ID + " " + c.Title, Time: seconds(c.DurationMS)}
		body := strings.Join(c.Details, "\n")
		switch c.Status {
		case runner.StatusFail:
			tc.Failure = &junitMessage{Message: c.Message, Text: body}
			suite.Failures++
		case runner.StatusError:
			tc.Error = &junitMessage{Message: c.Error, Text: strings.TrimSpace(c.Output + "\n" + c.Stderr)}
			suite.Errors++
		case runner.StatusWaived:
			msg := "waived"
			if c.Waiver != nil {
				msg += ": " + c.Waiver.Reason
			}
			tc.Skipped = &junitMessage{Message: msg}
			suite.Skipped++
		}
		suite.Cases = append(suite.Cases, tc)
	}
	suite.Tests = len(suite.Cases)
	doc := junitSuites{Name: "secbaseline", Tests: suite.Tests, Failures: suite.Failures, Errors: suite.Errors,
		Skipped: suite.Skipped, Time: suite.Time, Suites: []junitSuite{suite}}
	if _, err := io.WriteString(w, xml.Header); err != nil {
		return err
	}
	enc := xml.NewEncoder(w)
	enc.Indent("", "  ")
	if err := enc.Encode(doc); err != nil {
		return err
	}
	_, err := io.WriteString(w, "\n")
	return err
}

// --- CSV -------------------------------------------------------------------

// WriteCSV writes one row per check, for spreadsheets.
func WriteCSV(w io.Writer, rep *runner.Report) error {
	cw := csv.NewWriter(w)
	subject := rep.Subject()
	cw.Write([]string{"platform", "subject", "key", "id", "title", "section", "status", "message",
		"details", "waiver_reason", "waiver_approved_by", "waiver_expires", "exit_code", "duration_ms", "started_at"})
	for _, c := range rep.Checks {
		var reason, by, expires string
		if c.Waiver != nil {
			reason, by, expires = c.Waiver.Reason, c.Waiver.ApprovedBy, c.Waiver.Expires
		}
		cw.Write([]string{rep.Platform.Key, subject, c.Key, c.ID, c.Title, c.Section, c.Status,
			firstNonEmpty(c.Message, c.Error), strings.Join(c.Details, " | "), reason, by, expires,
			strconv.Itoa(c.ExitCode), strconv.FormatInt(c.DurationMS, 10), rep.StartedAt.UTC().Format(time.RFC3339)})
	}
	cw.Flush()
	return cw.Error()
}

func firstNonEmpty(s ...string) string {
	for _, x := range s {
		if x != "" {
			return x
		}
	}
	return ""
}

// WriteFormat renders rep in the named format.
func WriteFormat(w io.Writer, format string, rep *runner.Report) error {
	f, ok := Formats[format]
	if !ok {
		return fmt.Errorf("unknown format %q (html, sarif, junit, csv)", format)
	}
	return f(w, rep)
}
