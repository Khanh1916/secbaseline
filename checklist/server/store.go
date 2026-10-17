package server

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
	"sync"

	"checklist/drift"
	"checklist/runner"
)

// Store keeps reports as JSON files: <dir>/<subject id>/<timestamp>-<hash>.json.
// The subject id is "<platform>_<host or device>", so a host audited for two
// platforms keeps two histories.
type Store struct {
	dir string
	mu  sync.Mutex
}

func NewStore(dir string) (*Store, error) {
	if err := os.MkdirAll(dir, 0o750); err != nil {
		return nil, err
	}
	return &Store{dir: dir}, nil
}

var unsafeChars = regexp.MustCompile(`[^A-Za-z0-9._-]+`)

func subjectID(rep *runner.Report) string {
	id := unsafeChars.ReplaceAllString(rep.Platform.Key+"_"+drift.Subject(rep), "-")
	return strings.Trim(id, ".-")
}

var validName = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9._-]*$`)

// Save validates and stores a report, returning "<subject>/<file>".
func (s *Store) Save(data []byte) (string, error) {
	var rep runner.Report
	if err := json.Unmarshal(data, &rep); err != nil {
		return "", fmt.Errorf("invalid report: %w", err)
	}
	if rep.SchemaVersion != runner.SchemaVersion {
		return "", fmt.Errorf("unsupported schema_version %d", rep.SchemaVersion)
	}
	if rep.Platform.Key == "" || rep.StartedAt.IsZero() {
		return "", errors.New("report is missing platform or started_at")
	}
	subject := subjectID(&rep)
	if !validName.MatchString(subject) {
		return "", errors.New("report has no usable host or device name")
	}
	sum := sha256.Sum256(data)
	name := rep.StartedAt.UTC().Format("20060102T150405Z") + "-" + hex.EncodeToString(sum[:4]) + ".json"

	s.mu.Lock()
	defer s.mu.Unlock()
	dir := filepath.Join(s.dir, subject)
	if err := os.MkdirAll(dir, 0o750); err != nil {
		return "", err
	}
	if err := os.WriteFile(filepath.Join(dir, name), data, 0o640); err != nil {
		return "", err
	}
	return subject + "/" + name, nil
}

// Subjects lists subject ids, sorted.
func (s *Store) Subjects() ([]string, error) {
	entries, err := os.ReadDir(s.dir)
	if err != nil {
		return nil, err
	}
	var out []string
	for _, e := range entries {
		if e.IsDir() && validName.MatchString(e.Name()) {
			out = append(out, e.Name())
		}
	}
	return out, nil
}

// History lists a subject's report file names, oldest first.
func (s *Store) History(subject string) ([]string, error) {
	if !validName.MatchString(subject) {
		return nil, os.ErrNotExist
	}
	entries, err := os.ReadDir(filepath.Join(s.dir, subject))
	if err != nil {
		return nil, err
	}
	var out []string
	for _, e := range entries {
		if !e.IsDir() && strings.HasSuffix(e.Name(), ".json") && validName.MatchString(e.Name()) {
			out = append(out, e.Name())
		}
	}
	slices.Sort(out) // names start with a UTC timestamp
	return out, nil
}

// Load reads one stored report.
func (s *Store) Load(subject, name string) (*runner.Report, error) {
	if !validName.MatchString(subject) || !validName.MatchString(name) {
		return nil, os.ErrNotExist
	}
	data, err := os.ReadFile(filepath.Join(s.dir, subject, name))
	if err != nil {
		return nil, err
	}
	var rep runner.Report
	if err := json.Unmarshal(data, &rep); err != nil {
		return nil, err
	}
	return &rep, nil
}
