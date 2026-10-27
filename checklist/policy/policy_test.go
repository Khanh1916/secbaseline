package policy

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestSelects(t *testing.T) {
	p := &Policy{Include: []string{"linux"}, Exclude: []string{"linux.mac", "linux.ssh.ssh_protocol_2"}}
	for key, want := range map[string]bool{
		"linux.ssh.ssh_root_login_disabled": true,
		"linux.ssh.ssh_protocol_2":          false,
		"linux.mac.selinux_enforcing":       false,
		"linux.machine.x":                   true, // prefix match is per key segment
		"windows.password.history":          false,
	} {
		if got := p.Selects(key); got != want {
			t.Errorf("Selects(%s) = %v, want %v", key, got, want)
		}
	}
	if !(*Policy)(nil).Selects("anything") {
		t.Error("a nil policy selects everything")
	}
}

func TestWaiverMatching(t *testing.T) {
	w := Waiver{Key: "linux.filesystem.tmp_partition", Hosts: []string{"web-*", "db01"}, Platforms: []string{"ubuntu"}, Expires: "2027-06-30"}
	cases := []struct {
		platform, subject, key string
		want                   bool
	}{
		{"ubuntu", "web-07", "linux.filesystem.tmp_partition", true},
		{"ubuntu", "WEB-07", "linux.filesystem.tmp_partition", true},
		{"ubuntu", "db01", "linux.filesystem.tmp_partition", true},
		{"ubuntu", "app01", "linux.filesystem.tmp_partition", false},
		{"redhat", "web-07", "linux.filesystem.tmp_partition", false},
		{"ubuntu", "web-07", "linux.filesystem.var_partition", false},
	}
	for _, c := range cases {
		if got := w.Applies(c.platform, c.subject, c.key); got != c.want {
			t.Errorf("Applies(%s, %s, %s) = %v", c.platform, c.subject, c.key, got)
		}
	}
	if w.Expired(time.Date(2027, 6, 30, 23, 0, 0, 0, time.UTC)) {
		t.Error("a waiver is valid through its expiry date")
	}
	if !w.Expired(time.Date(2027, 7, 1, 1, 0, 0, 0, time.UTC)) {
		t.Error("a waiver expires the day after its expiry date")
	}
}

func TestLoadValidates(t *testing.T) {
	dir := t.TempDir()
	write := func(name, body string) string {
		p := filepath.Join(dir, name)
		if err := os.WriteFile(p, []byte(body), 0o644); err != nil {
			t.Fatal(err)
		}
		return p
	}
	known := func(k string) bool { return k == "linux.ssh.a" }

	good := write("good.yaml", "name: web\nexclude: [linux.mac]\nwaivers:\n  - key: linux.ssh.a\n    reason: legacy client\n    expires: 2027-01-31\n")
	if p, err := Load(good, known); err != nil || len(p.Waivers) != 1 {
		t.Fatalf("Load(good) = %v, %v", p, err)
	}

	bad := write("bad.yaml", "name: web\nwaivers:\n  - key: linux.ssh.typo\n    expires: someday\n    hosts: ['[']\n")
	_, err := Load(bad, known)
	for _, want := range []string{"unknown control key", "reason is required", "expires must be a date", "bad host pattern"} {
		if err == nil || !strings.Contains(err.Error(), want) {
			t.Errorf("error %v does not mention %q", err, want)
		}
	}

	if _, err := Load(write("typo.yaml", "name: x\nexlude: [linux]\n"), known); err == nil {
		t.Error("unknown fields such as a misspelled exclude must be rejected")
	}
}
