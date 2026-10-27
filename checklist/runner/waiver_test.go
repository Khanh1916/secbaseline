package runner

import (
	"testing"
	"time"

	"checklist/policy"
)

func TestApplyWaivers(t *testing.T) {
	pol := &policy.Policy{Name: "web", Waivers: []policy.Waiver{
		{Key: "a", Hosts: []string{"web-*"}, Reason: "accepted", ApprovedBy: "secteam", Expires: "2027-06-30"},
		{Key: "b", Reason: "old", Expires: "2026-01-31"},
		{Key: "c", Reason: "fixed since", Expires: "2027-06-30"},
		{Key: "d", Hosts: []string{"db-*"}, Reason: "other hosts", Expires: "2027-06-30"},
	}}
	rep := &Report{
		Platform: PlatformInfo{Key: "ubuntu"},
		Host:     Host{Hostname: "web-01"},
		Policy:   &PolicyInfo{Name: "web"},
		Checks: []CheckResult{
			{Key: "a", Status: StatusFail},
			{Key: "b", Status: StatusFail},
			{Key: "c", Status: StatusPass},
			{Key: "d", Status: StatusFail},
		},
	}
	applyWaivers(rep, pol, time.Date(2026, 10, 27, 0, 0, 0, 0, time.UTC))

	if c := rep.Checks[0]; c.Status != StatusWaived || c.Waiver == nil || c.Waiver.ApprovedBy != "secteam" {
		t.Errorf("active waiver not applied: %+v", c)
	}
	if rep.Checks[1].Status != StatusFail || len(rep.Policy.ExpiredWaivers) != 1 || rep.Policy.ExpiredWaivers[0].Key != "b" {
		t.Errorf("expired waiver must not apply: %+v %+v", rep.Checks[1], rep.Policy.ExpiredWaivers)
	}
	if len(rep.Policy.UnusedWaivers) != 1 || rep.Policy.UnusedWaivers[0].Key != "c" {
		t.Errorf("unused waivers = %+v", rep.Policy.UnusedWaivers)
	}
	if rep.Checks[3].Status != StatusFail {
		t.Errorf("waiver for other hosts applied: %+v", rep.Checks[3])
	}
	// One pass ("c") and two failures ("b", "d"); the waived check is left out of the score.
	if s := summarize(rep.Checks); s.Waived != 1 || s.Pass != 1 || s.Fail != 2 || s.Score != 33.3 {
		t.Errorf("summary = %+v", s)
	}
}
