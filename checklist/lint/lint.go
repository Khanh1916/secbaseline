// Package lint checks the catalog against the script tree and the scripts
// against the output contract described in the repository README.
package lint

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"strconv"
	"strings"

	"checklist/catalog"
	"checklist/collector"
	"checklist/policy"
)

type Problem struct {
	Path string
	Line int
	Msg  string
}

func (p Problem) String() string {
	if p.Line > 0 {
		return fmt.Sprintf("%s:%d: %s", p.Path, p.Line, p.Msg)
	}
	return fmt.Sprintf("%s: %s", p.Path, p.Msg)
}

var scriptName = regexp.MustCompile(`^(\d+)\.(sh|ps1)$`)

// Run returns every problem found, ordered by path and line.
func Run(cat *catalog.Catalog) []Problem {
	l := &linter{cat: cat}
	l.catalog()
	for _, name := range cat.PlatformNames() {
		p := cat.Platforms[name]
		entries, err := os.ReadDir(filepath.Join(cat.Root, name))
		if err != nil {
			continue // reported by catalog()
		}
		for _, e := range entries {
			if e.IsDir() || !scriptName.MatchString(e.Name()) {
				continue
			}
			path := filepath.Join(cat.Root, name, e.Name())
			if p.Kind == catalog.KindNetwork {
				l.networkScript(path)
			} else {
				l.hostScript(path, p.Kind == catalog.KindWindows)
			}
		}
	}
	l.policies()
	slices.SortFunc(l.problems, func(a, b Problem) int {
		if c := strings.Compare(a.Path, b.Path); c != 0 {
			return c
		}
		return a.Line - b.Line
	})
	return l.problems
}

type linter struct {
	cat      *catalog.Catalog
	problems []Problem
}

func (l *linter) add(path string, line int, format string, args ...any) {
	if rel, err := filepath.Rel(l.cat.Root, path); err == nil {
		path = filepath.ToSlash(rel)
	}
	l.problems = append(l.problems, Problem{Path: path, Line: line, Msg: fmt.Sprintf(format, args...)})
}

func (l *linter) catalog() {
	c, file := l.cat, filepath.Join(l.cat.Root, catalog.FileName)
	if c.Version != 1 {
		l.add(file, 0, "unsupported version %d", c.Version)
	}
	for name, p := range c.Platforms {
		if !slices.Contains([]string{catalog.KindLinux, catalog.KindWindows, catalog.KindNetwork}, p.Kind) {
			l.add(file, 0, "platform %s: unknown kind %q", name, p.Kind)
		}
		if st, err := os.Stat(filepath.Join(c.Root, name)); err != nil || !st.IsDir() {
			l.add(file, 0, "platform %s: directory %s/ not found", name, name)
		}
	}

	keys := map[string]bool{}
	used := map[string][]string{} // "platform/id" -> keys
	for _, it := range c.Controls {
		l.item(file, it, keys)
		for platform, id := range it.IDs {
			if _, ok := c.Platforms[platform]; !ok {
				continue
			}
			ref := platform + "/" + strconv.Itoa(id)
			used[ref] = append(used[ref], it.Key)
			if _, err := os.Stat(c.ScriptPath(platform, id)); err != nil {
				l.add(file, 0, "%s: script %s%s not found", it.Key, ref, c.Platforms[platform].Extension())
			}
		}
	}
	for ref, ks := range used {
		if len(ks) > 1 {
			l.add(file, 0, "script %s is used by several controls: %s", ref, strings.Join(ks, ", "))
		}
	}
	for _, name := range c.PlatformNames() {
		entries, _ := os.ReadDir(filepath.Join(c.Root, name))
		for _, e := range entries {
			if m := scriptName.FindStringSubmatch(e.Name()); m != nil && used[name+"/"+m[1]] == nil {
				l.add(filepath.Join(c.Root, name, e.Name()), 0, "script is not listed in %s", catalog.FileName)
			}
		}
	}

	for _, it := range c.Collectors {
		l.item(file, it, keys)
		if !slices.Contains([]string{"", "files", "folders"}, it.Needs) {
			l.add(file, 0, "%s: needs must be files or folders, not %q", it.Key, it.Needs)
		}
		for platform, id := range it.IDs {
			ref := platform + "/" + strconv.Itoa(id)
			if !collector.Known(strconv.Itoa(id)) {
				l.add(file, 0, "%s: id %d is not served by the Go collector", it.Key, id)
			}
			if used[ref] != nil {
				l.add(file, 0, "%s: id %s is also a control script", it.Key, ref)
			}
		}
	}
}

func (l *linter) item(file string, it catalog.Item, keys map[string]bool) {
	switch {
	case it.Key == "":
		l.add(file, 0, "entry without key (title %q)", it.Title)
	case keys[it.Key]:
		l.add(file, 0, "duplicate key %s", it.Key)
	}
	keys[it.Key] = true
	if it.Title == "" {
		l.add(file, 0, "%s: missing title", it.Key)
	}
	if len(it.IDs) == 0 {
		l.add(file, 0, "%s: no ids", it.Key)
	}
	for platform := range it.IDs {
		if _, ok := l.cat.Platforms[platform]; !ok {
			l.add(file, 0, "%s: unknown platform %q", it.Key, platform)
		}
	}
}

var (
	exitStmt    = regexp.MustCompile(`^\s*exit\b\s*([^\s;#]*)`)
	verdictSh   = regexp.MustCompile(`^\s*echo\s+(?:-e\s+)?"(PASS|FAIL): \S`)
	verdictPs   = regexp.MustCompile(`^\s*Write-Output\s+"(PASS|FAIL): \S`)
	outputSh    = regexp.MustCompile(`^\s*echo(\s|$)`)
	outputPs    = regexp.MustCompile(`^\s*Write-Output(\s|$)`)
	prefixed    = regexp.MustCompile(`^\s*(?:echo\s+(?:-e\s+)?|Write-Output\s+)"(PASS|FAIL|INFO): `)
	failedToken = regexp.MustCompile(`\bFAILED\b`)
	plainVerdct = regexp.MustCompile(`^\s*echo\s+"(PASS|FAIL)[^"]*"`)
	// Usage and error text on stdout hides the verdict of a network check.
	strayMsg = regexp.MustCompile(`^\s*echo\s+"(Usage|ERROR|Error|File not found)\b`)
)

type line struct {
	n    int
	text string
}

func readScript(l *linter, path string, ps bool) ([]line, bool) {
	data, err := os.ReadFile(path)
	if err != nil {
		l.add(path, 0, "%v", err)
		return nil, false
	}
	if !ps && bytes.Contains(data, []byte("\r")) {
		l.add(path, 0, "CRLF line endings; shell scripts must use LF")
	}
	text := strings.ReplaceAll(string(data), "\r\n", "\n")
	raw := strings.Split(text, "\n")
	if !ps && !strings.HasPrefix(raw[0], "#!") {
		l.add(path, 1, "first line must be a shebang (#!/bin/bash)")
	}
	var code []line
	for i, t := range raw {
		for _, r := range t {
			if r > 127 {
				l.add(path, i+1, "non-ASCII character %q", r)
				break
			}
		}
		s := strings.TrimSpace(t)
		if s != "" && !strings.HasPrefix(s, "#") {
			code = append(code, line{i + 1, t})
		}
	}
	return code, true
}

// hostScript enforces the host contract: INFO lines, then one PASS:/FAIL: line, then exit 0/1.
func (l *linter) hostScript(path string, ps bool) {
	code, ok := readScript(l, path, ps)
	if !ok {
		return
	}
	verdict, output := verdictSh, outputSh
	if ps {
		verdict, output = verdictPs, outputPs
	}
	for i, c := range code {
		if m := exitStmt.FindStringSubmatch(c.text); m != nil {
			if m[1] != "0" && m[1] != "1" {
				l.add(path, c.n, "exit code must be 0 or 1, got %q", m[1])
				continue
			}
			want := map[string]string{"0": "PASS", "1": "FAIL"}[m[1]]
			if i == 0 {
				l.add(path, c.n, "exit %s without a preceding %s: line", m[1], want)
				continue
			}
			v := verdict.FindStringSubmatch(code[i-1].text)
			switch {
			case v == nil:
				l.add(path, c.n, "exit %s must directly follow a %s: line", m[1], want)
			case v[1] != want:
				l.add(path, code[i-1].n, "%s: line followed by exit %s", v[1], m[1])
			}
			continue
		}
		t := c.text
		if output.MatchString(t) && !strings.ContainsAny(t, "|>") && !prefixed.MatchString(t) {
			l.add(path, c.n, "output must start with PASS:, FAIL: or INFO:")
		}
	}
	if !endsWithExit(code, ps) {
		l.add(path, 0, "script can finish without exit 0/1")
	}
}

// endsWithExit reports whether the script's last statement is an exit, or a
// closing if/else whose every branch ends in exit.
func endsWithExit(code []line, ps bool) bool {
	if len(code) == 0 {
		return false
	}
	last := strings.TrimSpace(code[len(code)-1].text)
	if exitStmt.MatchString(last) {
		return true
	}
	if ps || last != "fi" {
		return false
	}
	depth, hasElse := 0, false
	ends := []string{code[len(code)-2].text}
	for k := len(code) - 2; k >= 0; k-- {
		s := strings.TrimSpace(code[k].text)
		switch {
		case s == "fi":
			depth++
		case strings.HasPrefix(s, "if "):
			if depth == 0 {
				if !hasElse {
					return false
				}
				for _, e := range ends {
					if !exitStmt.MatchString(e) && strings.TrimSpace(e) != "fi" {
						return false
					}
				}
				return true
			}
			depth--
		case depth == 0 && (s == "else" || strings.HasPrefix(s, "elif ")):
			hasElse = hasElse || s == "else"
			ends = append(ends, code[k-1].text)
		}
	}
	return false
}

// networkScript enforces the network contract: stdout is exactly PASS or FAIL.
func (l *linter) networkScript(path string) {
	code, ok := readScript(l, path, false)
	if !ok {
		return
	}
	for _, c := range code {
		if failedToken.MatchString(c.text) {
			l.add(path, c.n, "use FAIL, not FAILED")
		}
		if m := plainVerdct.FindString(c.text); m != "" && !strings.Contains(m, `"PASS"`) && !strings.Contains(m, `"FAIL"`) {
			l.add(path, c.n, `network verdicts are exactly "PASS" or "FAIL"`)
		}
		if strayMsg.MatchString(c.text) && !strings.Contains(c.text, ">&2") {
			l.add(path, c.n, `print "FAIL" (or write to stderr) instead of a usage or error message`)
		}
	}
}

// policies validates every policy file shipped in policies/.
func (l *linter) policies() {
	files, _ := filepath.Glob(filepath.Join(l.cat.Root, "policies", "*.yaml"))
	for _, f := range files {
		if _, err := policy.Load(f, l.cat.HasKey); err != nil {
			l.add(f, 0, "%v", err)
		}
	}
}
