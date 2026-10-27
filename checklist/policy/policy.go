// Package policy loads policy files: which controls apply (a profile) and which
// failing controls are accepted exceptions (waivers).
package policy

import (
	"bytes"
	"errors"
	"fmt"
	"os"
	"path"
	"strings"
	"time"

	"gopkg.in/yaml.v3"
)

const dateLayout = "2006-01-02"

type Policy struct {
	Name        string   `yaml:"name"`
	Description string   `yaml:"description"`
	Include     []string `yaml:"include"`
	Exclude     []string `yaml:"exclude"`
	Waivers     []Waiver `yaml:"waivers"`
}

// Waiver accepts the failure of one control on matching hosts until Expires.
type Waiver struct {
	Key        string   `yaml:"key"`
	Hosts      []string `yaml:"hosts"`     // glob patterns on the host or device name; empty matches all
	Platforms  []string `yaml:"platforms"` // platform keys; empty matches all
	Reason     string   `yaml:"reason"`
	ApprovedBy string   `yaml:"approved_by"`
	Expires    string   `yaml:"expires"` // YYYY-MM-DD, inclusive
	Ticket     string   `yaml:"ticket"`
}

// Load reads and validates a policy file. knownKey, when not nil, reports
// whether a control key exists, so typos are caught before a run.
func Load(file string, knownKey func(string) bool) (*Policy, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}
	var p Policy
	dec := yaml.NewDecoder(bytes.NewReader(data))
	dec.KnownFields(true)
	if err := dec.Decode(&p); err != nil {
		return nil, fmt.Errorf("%s: %w", file, err)
	}
	if errs := p.Validate(knownKey); len(errs) > 0 {
		return nil, fmt.Errorf("%s: %w", file, errors.Join(errs...))
	}
	return &p, nil
}

// Validate returns every problem in the policy.
func (p *Policy) Validate(knownKey func(string) bool) []error {
	var errs []error
	if p.Name == "" {
		errs = append(errs, errors.New("name is required"))
	}
	for i, w := range p.Waivers {
		at := fmt.Sprintf("waivers[%d] (%s)", i, w.Key)
		if w.Key == "" {
			errs = append(errs, fmt.Errorf("%s: key is required", at))
		} else if knownKey != nil && !knownKey(w.Key) {
			errs = append(errs, fmt.Errorf("%s: unknown control key", at))
		}
		if strings.TrimSpace(w.Reason) == "" {
			errs = append(errs, fmt.Errorf("%s: reason is required", at))
		}
		if _, err := time.Parse(dateLayout, w.Expires); err != nil {
			errs = append(errs, fmt.Errorf("%s: expires must be a date like 2027-06-30", at))
		}
		for _, h := range w.Hosts {
			if _, err := path.Match(h, ""); err != nil {
				errs = append(errs, fmt.Errorf("%s: bad host pattern %q", at, h))
			}
		}
	}
	return errs
}

// Selects reports whether the policy's profile includes a control key.
func (p *Policy) Selects(key string) bool {
	if p == nil {
		return true
	}
	if len(p.Include) > 0 && !matchesAny(key, p.Include) {
		return false
	}
	return !matchesAny(key, p.Exclude)
}

func matchesAny(key string, prefixes []string) bool {
	for _, pre := range prefixes {
		pre = strings.TrimSuffix(pre, ".")
		if key == pre || strings.HasPrefix(key, pre+".") {
			return true
		}
	}
	return false
}

// Applies reports whether the waiver covers this control on this platform and host.
func (w Waiver) Applies(platform, subject, key string) bool {
	if w.Key != key {
		return false
	}
	if len(w.Platforms) > 0 && !contains(w.Platforms, platform) {
		return false
	}
	if len(w.Hosts) == 0 {
		return true
	}
	for _, h := range w.Hosts {
		if ok, _ := path.Match(strings.ToLower(h), strings.ToLower(subject)); ok {
			return true
		}
	}
	return false
}

// Expired reports whether the waiver has run out at now (it is valid through its expiry date, UTC).
func (w Waiver) Expired(now time.Time) bool {
	t, err := time.Parse(dateLayout, w.Expires)
	return err != nil || now.UTC().After(t.Add(24*time.Hour))
}

// Find returns the first waiver covering the control, if any.
func (p *Policy) Find(platform, subject, key string) (Waiver, bool) {
	if p == nil {
		return Waiver{}, false
	}
	for _, w := range p.Waivers {
		if w.Applies(platform, subject, key) {
			return w, true
		}
	}
	return Waiver{}, false
}

func contains(list []string, s string) bool {
	for _, x := range list {
		if x == s {
			return true
		}
	}
	return false
}
