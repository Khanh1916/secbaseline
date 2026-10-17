package runner

import (
	"fmt"
	"regexp"
	"strings"
)

var verdictLine = regexp.MustCompile(`^(PASS|FAIL)(?::\s*(.*))?$`)

// parsed is a check's stdout split according to the output contract:
// zero or more "INFO: ..." lines followed by one "PASS: ..." or "FAIL: ..." line.
type parsed struct {
	verdict string // "PASS", "FAIL" or "" when no verdict line was found
	message string
	details []string
	extra   []string // lines that follow neither convention
}

func parseOutput(stdout string) parsed {
	var p parsed
	lines := strings.Split(strings.ReplaceAll(stdout, "\r\n", "\n"), "\n")
	last := -1
	for i, l := range lines {
		if verdictLine.MatchString(strings.TrimSpace(l)) {
			last = i
		}
	}
	for i, l := range lines {
		l = strings.TrimRight(l, " \t\r")
		switch {
		case i == last:
			m := verdictLine.FindStringSubmatch(strings.TrimSpace(l))
			p.verdict, p.message = m[1], m[2]
		case strings.HasPrefix(l, "INFO:"):
			p.details = append(p.details, strings.TrimSpace(strings.TrimPrefix(l, "INFO:")))
		case strings.TrimSpace(l) != "":
			p.extra = append(p.extra, l)
		}
	}
	return p
}

// classify turns a finished script into a status, enforcing that the exit code
// and the verdict line agree. Disagreement is reported as an error, not guessed at.
func classify(p parsed, exitCode int) (status, problem string) {
	switch {
	case p.verdict == "":
		return StatusError, fmt.Sprintf("no PASS/FAIL verdict line in output (exit code %d)", exitCode)
	case exitCode == 0 && p.verdict == "PASS":
		return StatusPass, ""
	case exitCode == 1 && p.verdict == "FAIL":
		return StatusFail, ""
	default:
		return StatusError, fmt.Sprintf("exit code %d does not match verdict %s", exitCode, p.verdict)
	}
}
