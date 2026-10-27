// Package drift compares two reports: which checks changed verdict and which
// inventory lines appeared or disappeared.
package drift

import (
	"fmt"
	"io"
	"slices"
	"strings"

	"checklist/runner"
)

// Side identifies one of the two compared reports.
type Side struct {
	Platform  string  `json:"platform"`
	Subject   string  `json:"subject"`
	StartedAt string  `json:"started_at"`
	Score     float64 `json:"score"`
}

type CheckChange struct {
	Key     string `json:"key"`
	ID      string `json:"id"`
	Title   string `json:"title"`
	From    string `json:"from"`
	To      string `json:"to"`
	Message string `json:"message,omitempty"`
}

type InventoryChange struct {
	Key     string   `json:"key"`
	Title   string   `json:"title"`
	Added   []string `json:"added,omitempty"`
	Removed []string `json:"removed,omitempty"`
	Note    string   `json:"note,omitempty"`
}

type Result struct {
	Old         Side              `json:"old"`
	New         Side              `json:"new"`
	ScoreDelta  float64           `json:"score_delta"`
	Regressions []CheckChange     `json:"regressions"`
	Fixed       []CheckChange     `json:"fixed"`
	Changed     []CheckChange     `json:"changed"` // transitions into or out of error, added, removed
	Inventory   []InventoryChange `json:"inventory"`
}

// HasDrift reports whether anything got worse or the inventory changed.
func (r *Result) HasDrift() bool {
	return len(r.Regressions)+len(r.Changed)+len(r.Inventory) > 0
}

// Subject is the device hostname for network reports and the host name otherwise.
func Subject(rep *runner.Report) string { return rep.Subject() }

func side(rep *runner.Report) Side {
	return Side{Platform: rep.Platform.Key, Subject: Subject(rep), StartedAt: rep.StartedAt.Format("2006-01-02 15:04 MST"), Score: rep.Summary.Score}
}

// Compare matches checks and collectors by key. The two reports may come from
// different hosts, e.g. a golden baseline and a production server.
func Compare(old, cur *runner.Report) *Result {
	r := &Result{Old: side(old), New: side(cur)}
	r.ScoreDelta = round1(cur.Summary.Score - old.Summary.Score)

	before := map[string]runner.CheckResult{}
	for _, c := range old.Checks {
		before[c.Key] = c
	}
	seen := map[string]bool{}
	for _, c := range cur.Checks {
		seen[c.Key] = true
		ch := CheckChange{Key: c.Key, ID: c.ID, Title: c.Title, To: c.Status, Message: firstNonEmpty(c.Message, c.Error)}
		prev, ok := before[c.Key]
		if !ok {
			ch.From = "absent"
			r.Changed = append(r.Changed, ch)
			continue
		}
		ch.From = prev.Status
		switch {
		case prev.Status == c.Status:
		case prev.Status == runner.StatusPass && c.Status == runner.StatusFail:
			r.Regressions = append(r.Regressions, ch)
		case prev.Status == runner.StatusFail && c.Status == runner.StatusPass:
			r.Fixed = append(r.Fixed, ch)
		default:
			r.Changed = append(r.Changed, ch)
		}
	}
	for _, c := range old.Checks {
		if !seen[c.Key] {
			r.Changed = append(r.Changed, CheckChange{Key: c.Key, ID: c.ID, Title: c.Title, From: c.Status, To: "absent"})
		}
	}

	prevInv := map[string]runner.CollectorResult{}
	for _, c := range old.Collectors {
		prevInv[c.Key] = c
	}
	for _, c := range cur.Collectors {
		prev, ok := prevInv[c.Key]
		if !ok || prev.Status != runner.StatusOK || c.Status != runner.StatusOK {
			if ok && prev.Status != c.Status {
				r.Inventory = append(r.Inventory, InventoryChange{Key: c.Key, Title: c.Title, Note: fmt.Sprintf("status %s -> %s", prev.Status, c.Status)})
			}
			continue
		}
		added, removed := lineDiff(prev.Output, c.Output)
		if len(added)+len(removed) > 0 {
			r.Inventory = append(r.Inventory, InventoryChange{Key: c.Key, Title: c.Title, Added: added, Removed: removed})
		}
	}
	return r
}

// lineDiff returns the lines only in b (added) and only in a (removed),
// treating each output as a multiset of lines. Collector output is sorted, so
// order carries no meaning.
func lineDiff(a, b string) (added, removed []string) {
	count := map[string]int{}
	for _, l := range lines(a) {
		count[l]++
	}
	for _, l := range lines(b) {
		if count[l] > 0 {
			count[l]--
		} else {
			added = append(added, l)
		}
	}
	for _, l := range lines(a) {
		if count[l] > 0 {
			count[l]--
			removed = append(removed, l)
		}
	}
	return added, removed
}

func lines(s string) []string {
	var out []string
	for _, l := range strings.Split(strings.ReplaceAll(s, "\r\n", "\n"), "\n") {
		if l = strings.TrimRight(l, " \t"); strings.TrimSpace(l) != "" {
			out = append(out, l)
		}
	}
	return out
}

// WriteText prints a human-readable summary of r.
func WriteText(w io.Writer, r *Result) {
	fmt.Fprintf(w, "%s %s (%s)  ->  %s %s (%s)\n", r.Old.Platform, r.Old.Subject, r.Old.StartedAt, r.New.Platform, r.New.Subject, r.New.StartedAt)
	fmt.Fprintf(w, "Score: %.1f%% -> %.1f%% (%+.1f)\n", r.Old.Score, r.New.Score, r.ScoreDelta)
	section := func(title string, cs []CheckChange) {
		if len(cs) == 0 {
			return
		}
		fmt.Fprintf(w, "\n%s (%d)\n", title, len(cs))
		for _, c := range cs {
			fmt.Fprintf(w, "  %-6s %-6s -> %-6s %s  %s\n", c.ID, c.From, c.To, c.Key, c.Title)
			if c.Message != "" {
				fmt.Fprintf(w, "         %s\n", c.Message)
			}
		}
	}
	section("Regressions", r.Regressions)
	section("Fixed", r.Fixed)
	section("Other changes", r.Changed)
	if len(r.Inventory) > 0 {
		fmt.Fprintf(w, "\nInventory changes (%d)\n", len(r.Inventory))
		for _, c := range r.Inventory {
			fmt.Fprintf(w, "  %s  %s\n", c.Key, c.Title)
			if c.Note != "" {
				fmt.Fprintf(w, "    %s\n", c.Note)
			}
			for _, l := range c.Added {
				fmt.Fprintf(w, "    + %s\n", l)
			}
			for _, l := range c.Removed {
				fmt.Fprintf(w, "    - %s\n", l)
			}
		}
	}
	if len(r.Regressions)+len(r.Fixed)+len(r.Changed)+len(r.Inventory) == 0 {
		fmt.Fprintln(w, "\nNo changes.")
	}
}

func firstNonEmpty(s ...string) string {
	if i := slices.IndexFunc(s, func(x string) bool { return x != "" }); i >= 0 {
		return s[i]
	}
	return ""
}

func round1(f float64) float64 {
	if f < 0 {
		return -round1(-f)
	}
	return float64(int(f*10+0.5)) / 10
}
