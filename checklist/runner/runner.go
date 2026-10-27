// Package runner executes a platform's checks and collectors and builds a Report.
package runner

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"

	"checklist/catalog"
	"checklist/collector"
	"checklist/policy"
)

const maxOutput = 1 << 20 // per stream, per script

type Options struct {
	Platform   string
	Config     string // saved device configuration, network platforms only
	Only       []string
	Jobs       int
	Timeout    time.Duration
	Shell      string // interpreter for .sh scripts
	Collectors bool
	Input      collector.Input
	Version    string
	Policy     *policy.Policy // optional profile and waivers
	Now        func() time.Time
}

// Run executes every check (and, unless disabled, every collector) the catalog
// lists for opts.Platform. Failing checks are results, not errors; an error is
// returned only when the run itself cannot proceed.
func Run(ctx context.Context, cat *catalog.Catalog, opts Options) (*Report, error) {
	p, err := cat.Platform(opts.Platform)
	if err != nil {
		return nil, err
	}
	if opts.Jobs < 1 {
		opts.Jobs = 1
	}
	if opts.Shell == "" {
		opts.Shell = "bash"
	}

	rep := &Report{
		SchemaVersion: SchemaVersion,
		Tool:          Tool{Name: "checklist", Version: opts.Version},
		Platform:      PlatformInfo{Key: opts.Platform, Name: p.Name, Kind: p.Kind},
		Host:          hostInfo(),
		StartedAt:     time.Now().UTC(),
	}

	switch {
	case p.Kind == catalog.KindNetwork && opts.Config == "":
		return nil, errConfigRequired
	case p.Kind != catalog.KindNetwork && opts.Config != "":
		return nil, fmt.Errorf("--config is only used with network platforms, not %s", opts.Platform)
	case p.Kind == catalog.KindNetwork:
		var data []byte
		if rep.Target, data, err = describeTarget(opts.Config); err != nil {
			return nil, err
		}
		cfg, cleanup, err := lfConfig(rep.Target.ConfigFile, data)
		if err != nil {
			return nil, err
		}
		defer cleanup()
		opts.Config = cfg
	}

	controls := selectItems(cat.ControlsFor(opts.Platform), opts.Only)
	if opts.Policy != nil {
		rep.Policy = &PolicyInfo{Name: opts.Policy.Name, Description: opts.Policy.Description}
		kept := controls[:0:0]
		for _, it := range controls {
			if opts.Policy.Selects(it.Key) {
				kept = append(kept, it)
			} else {
				rep.Policy.Excluded++
			}
		}
		controls = kept
	}
	var collectors []catalog.Item
	if opts.Collectors && p.Kind != catalog.KindNetwork {
		collectors = selectItems(cat.CollectorsFor(opts.Platform), opts.Only)
	}
	if len(controls)+len(collectors) == 0 {
		return nil, fmt.Errorf("nothing to run for platform %s with this selection", opts.Platform)
	}
	rep.Checks = make([]CheckResult, len(controls))
	sem := make(chan struct{}, opts.Jobs)
	var wg sync.WaitGroup
	for i, it := range controls {
		wg.Add(1)
		go func() {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()
			rep.Checks[i] = runCheck(ctx, cat, p, it, opts)
		}()
	}
	wg.Wait()

	for _, it := range collectors {
		rep.Collectors = append(rep.Collectors, runCollector(ctx, it, opts))
	}

	now := time.Now
	if opts.Now != nil {
		now = opts.Now
	}
	applyWaivers(rep, opts.Policy, now())
	rep.FinishedAt = time.Now().UTC()
	rep.DurationMS = rep.FinishedAt.Sub(rep.StartedAt).Milliseconds()
	rep.Summary = summarize(rep.Checks)
	return rep, ctx.Err()
}

// selectItems keeps items whose key starts with one of the prefixes (all items when none are given).
func selectItems(items []catalog.Item, prefixes []string) []catalog.Item {
	if len(prefixes) == 0 {
		return items
	}
	var out []catalog.Item
	for _, it := range items {
		for _, pre := range prefixes {
			if it.Key == pre || strings.HasPrefix(it.Key, strings.TrimSuffix(pre, ".")+".") {
				out = append(out, it)
				break
			}
		}
	}
	return out
}

func runCheck(ctx context.Context, cat *catalog.Catalog, p catalog.Platform, it catalog.Item, opts Options) CheckResult {
	id := it.IDs[opts.Platform]
	r := CheckResult{Key: it.Key, ID: strconv.Itoa(id), Title: it.Title, Section: it.Section(), ExitCode: -1}
	path := cat.ScriptPath(opts.Platform, id)
	if _, err := os.Stat(path); err != nil {
		r.Status, r.Error = StatusError, "script not found: "+filepath.Base(path)
		return r
	}

	cctx, cancel := context.WithTimeout(ctx, opts.Timeout)
	defer cancel()
	cmd := scriptCommand(cctx, p.Kind, path, opts)
	var stdout, stderr capped
	cmd.Stdout, cmd.Stderr = &stdout, &stderr
	cmd.WaitDelay = 2 * time.Second

	start := time.Now()
	err := cmd.Run()
	r.DurationMS = time.Since(start).Milliseconds()
	if cmd.ProcessState != nil {
		r.ExitCode = cmd.ProcessState.ExitCode()
	}

	var exitErr *exec.ExitError
	switch {
	case errors.Is(cctx.Err(), context.DeadlineExceeded):
		r.Status, r.Error = StatusError, fmt.Sprintf("timed out after %s", opts.Timeout)
	case err != nil && !errors.As(err, &exitErr):
		r.Status, r.Error = StatusError, "could not run script: "+err.Error()
	default:
		out := parseOutput(stdout.String())
		r.Message, r.Details = out.message, out.details
		r.Status, r.Error = classify(out, r.ExitCode)
	}
	if r.Status == StatusError {
		r.Output, r.Stderr = strings.TrimSpace(stdout.String()), strings.TrimSpace(stderr.String())
	}
	return r
}

func scriptCommand(ctx context.Context, kind, path string, opts Options) *exec.Cmd {
	var cmd *exec.Cmd
	switch kind {
	case catalog.KindWindows:
		cmd = exec.CommandContext(ctx, "powershell", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", path)
	case catalog.KindNetwork:
		cmd = exec.CommandContext(ctx, opts.Shell, path, opts.Config)
	default:
		cmd = exec.CommandContext(ctx, opts.Shell, path)
	}
	cmd.Dir = filepath.Dir(path)
	if kind != catalog.KindWindows {
		// Scripts parse command output in English; a fixed locale keeps that stable.
		cmd.Env = append(os.Environ(), "LC_ALL=C")
	}
	return cmd
}

// collect runs a collector by ID; tests replace it.
var collect = collector.Run

func runCollector(ctx context.Context, it catalog.Item, opts Options) (r CollectorResult) {
	id := strconv.Itoa(it.IDs[opts.Platform])
	r = CollectorResult{Key: it.Key, ID: id, Title: it.Title}
	switch {
	case it.Needs == "files" && len(opts.Input.Files) == 0:
		r.Status, r.Error = StatusSkipped, "no files given (--files)"
		return r
	case it.Needs == "folders" && len(opts.Input.Folders) == 0:
		r.Status, r.Error = StatusSkipped, "no folders given (--folders)"
		return r
	}

	// Collectors are Go code that can block in a command or a file read that
	// nothing can interrupt, so the run stops waiting after the timeout and
	// leaves the collector to finish in the background.
	cctx, cancel := context.WithTimeout(ctx, opts.Timeout)
	defer cancel()
	type result struct {
		out string
		err error
	}
	done := make(chan result, 1) // buffered, so an abandoned collector can still finish
	run := collect
	start := time.Now()
	go func() {
		defer func() {
			if v := recover(); v != nil {
				done <- result{err: fmt.Errorf("collector panicked: %v", v)}
			}
		}()
		out, err := run(id, opts.Input)
		done <- result{out, err}
	}()

	select {
	case res := <-done:
		r.DurationMS = time.Since(start).Milliseconds()
		if res.err != nil {
			r.Status, r.Error = StatusError, res.err.Error()
			return r
		}
		r.Status, r.Output = StatusOK, strings.TrimRight(res.out, "\n")
	case <-cctx.Done():
		r.DurationMS = time.Since(start).Milliseconds()
		r.Status, r.Error = StatusError, cctx.Err().Error()
		if errors.Is(cctx.Err(), context.DeadlineExceeded) {
			r.Error = fmt.Sprintf("timed out after %s", opts.Timeout)
		}
	}
	return r
}

func describeTarget(path string) (*Target, []byte, error) {
	abs, err := filepath.Abs(path)
	if err != nil {
		return nil, nil, err
	}
	data, err := os.ReadFile(abs)
	if err != nil {
		return nil, nil, fmt.Errorf("read config: %w", err)
	}
	sum := sha256.Sum256(data)
	lf := bytes.ReplaceAll(data, []byte("\r\n"), []byte("\n"))
	return &Target{ConfigFile: abs, SHA256: hex.EncodeToString(sum[:]), DeviceHostname: parseDeviceHostname(lf)}, data, nil
}

// lfConfig returns a path to the configuration with LF line endings. Configurations
// saved from Windows terminals use CRLF, which breaks the scripts' line-anchored
// patterns on Linux, so such files are copied to a normalized temporary file.
func lfConfig(path string, data []byte) (string, func(), error) {
	if !bytes.Contains(data, []byte("\r\n")) {
		return path, func() {}, nil
	}
	f, err := os.CreateTemp("", "checklist-config-*.cfg")
	if err != nil {
		return "", nil, err
	}
	_, werr := f.Write(bytes.ReplaceAll(data, []byte("\r\n"), []byte("\n")))
	if cerr := f.Close(); werr == nil {
		werr = cerr
	}
	cleanup := func() { os.Remove(f.Name()) }
	if werr != nil {
		cleanup()
		return "", nil, werr
	}
	return f.Name(), cleanup, nil
}

func hostInfo() Host {
	h := Host{OS: runtime.GOOS, Arch: runtime.GOARCH}
	h.Hostname, _ = os.Hostname()
	h.Platform, h.PlatformVersion, h.KernelVersion = platformInfo()
	return h
}

// capped is a bytes.Buffer that silently drops writes past maxOutput.
type capped struct {
	buf       bytes.Buffer
	truncated bool
}

func (c *capped) Write(p []byte) (int, error) {
	if room := maxOutput - c.buf.Len(); room < len(p) {
		c.truncated = true
		if room > 0 {
			c.buf.Write(p[:room])
		}
		return len(p), nil
	}
	return c.buf.Write(p)
}

func (c *capped) String() string {
	if c.truncated {
		return c.buf.String() + "\n[output truncated]"
	}
	return c.buf.String()
}

// applyWaivers turns failing checks covered by an active waiver into StatusWaived
// and records expired and no-longer-needed waivers in rep.Policy.
func applyWaivers(rep *Report, pol *policy.Policy, now time.Time) {
	if pol == nil || rep.Policy == nil {
		return
	}
	subject := rep.Subject()
	for i := range rep.Checks {
		c := &rep.Checks[i]
		w, ok := pol.Find(rep.Platform.Key, subject, c.Key)
		if !ok {
			continue
		}
		note := WaiverNote{Key: c.Key, ID: c.ID, Title: c.Title, Reason: w.Reason, Expires: w.Expires}
		switch {
		case w.Expired(now):
			rep.Policy.ExpiredWaivers = append(rep.Policy.ExpiredWaivers, note)
		case c.Status == StatusFail:
			c.Status = StatusWaived
			c.Waiver = &Waiver{Reason: w.Reason, ApprovedBy: w.ApprovedBy, Expires: w.Expires, Ticket: w.Ticket}
		case c.Status == StatusPass:
			rep.Policy.UnusedWaivers = append(rep.Policy.UnusedWaivers, note)
		}
	}
}
