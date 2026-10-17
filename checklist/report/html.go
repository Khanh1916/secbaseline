// Package report renders a runner.Report as a self-contained HTML page.
package report

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"os"
	"strings"
	"time"

	"checklist/runner"
)

//go:embed template.html
var pageSource string

var sectionNames = map[string]string{
	"mac": "Mandatory access control", "ssh": "SSH", "tcp_wrappers": "TCP Wrappers",
	"auth": "Authentication", "network": "Network", "audit": "Auditing", "rights": "User rights",
	"defender": "Antivirus", "accounts": "Accounts", "lockout": "Account lockout",
}

var page = template.Must(template.New("report").Funcs(template.FuncMap{
	"duration": func(ms int64) string { return (time.Duration(ms) * time.Millisecond).Round(time.Millisecond).String() },
	"when":     func(t time.Time) string { return t.Local().Format("2006-01-02 15:04:05 MST") },
	"section": func(s string) string {
		if n, ok := sectionNames[s]; ok {
			return n
		}
		if s == "" {
			return "Other"
		}
		return strings.ToUpper(s[:1]) + strings.ReplaceAll(s[1:], "_", " ")
	},
	"upper": strings.ToUpper,
}).Parse(pageSource))

type section struct {
	Name   string
	Checks []runner.CheckResult
	Pass   int
	Fail   int
	Error  int
}

type view struct {
	*runner.Report
	Subject  string
	Sections []section
}

// WriteHTML renders rep to w.
func WriteHTML(w io.Writer, rep *runner.Report) error {
	v := view{Report: rep, Subject: rep.Host.Hostname}
	if rep.Target != nil {
		v.Subject = rep.Target.DeviceHostname
		if v.Subject == "" {
			v.Subject = rep.Target.ConfigFile
		}
	}
	index := map[string]int{}
	for _, c := range rep.Checks {
		i, ok := index[c.Section]
		if !ok {
			i = len(v.Sections)
			index[c.Section] = i
			v.Sections = append(v.Sections, section{Name: c.Section})
		}
		s := &v.Sections[i]
		s.Checks = append(s.Checks, c)
		switch c.Status {
		case runner.StatusPass:
			s.Pass++
		case runner.StatusFail:
			s.Fail++
		case runner.StatusError:
			s.Error++
		}
	}
	return page.Execute(w, v)
}

// LoadJSON reads a report written by `checklist run`.
func LoadJSON(path string) (*runner.Report, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var rep runner.Report
	if err := json.Unmarshal(data, &rep); err != nil {
		return nil, fmt.Errorf("parse %s: %w", path, err)
	}
	if rep.SchemaVersion != runner.SchemaVersion {
		return nil, fmt.Errorf("%s has schema_version %d; this build reads %d", path, rep.SchemaVersion, runner.SchemaVersion)
	}
	return &rep, nil
}
