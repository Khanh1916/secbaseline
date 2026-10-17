package lint

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"checklist/catalog"
)

func TestRepositoryIsClean(t *testing.T) {
	cat, err := catalog.Load(filepath.Join("..", ".."))
	if err != nil {
		t.Fatal(err)
	}
	for _, p := range Run(cat) {
		t.Error(p)
	}
}

func TestDetectsContractViolations(t *testing.T) {
	root := t.TempDir()
	write := func(rel, body string) {
		path := filepath.Join(root, rel)
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	write(catalog.FileName, `version: 1
platforms:
  ubuntu: {kind: linux, name: Ubuntu}
  iosxe: {kind: network, name: Cisco IOS XE}
controls:
  - {key: linux.a.good, title: Good, ids: {ubuntu: 1}}
  - {key: linux.a.bad, title: Bad, ids: {ubuntu: 2}}
  - {key: linux.a.missing, title: Missing, ids: {ubuntu: 3}}
  - {key: network.n, title: Net, ids: {iosxe: 7}}
`)
	write("ubuntu/1.sh", "#!/bin/bash\nif true; then\n  echo \"PASS: fine\"\n  exit 0\nfi\necho \"FAIL: not fine\"\nexit 1\n")
	write("ubuntu/2.sh", "\n#!/bin/bash\necho \"progress\"\necho \"FAIL: wrong code\"\nexit 0\nexit 2\n")
	write("ubuntu/9.sh", "#!/bin/bash\necho \"PASS: orphan\"\nexit 0\n")
	write("iosxe/7.sh", "#!/bin/bash\necho \"FAILED\"\nexit 1\n")

	cat, err := catalog.Load(root)
	if err != nil {
		t.Fatal(err)
	}
	var got []string
	for _, p := range Run(cat) {
		got = append(got, p.String())
	}
	joined := strings.Join(got, "\n")
	for _, want := range []string{
		"ubuntu/2.sh:1: first line must be a shebang",
		"ubuntu/2.sh:3: output must start with PASS:, FAIL: or INFO:",
		"ubuntu/2.sh:4: FAIL: line followed by exit 0",
		"ubuntu/2.sh:6: exit code must be 0 or 1",
		"linux.a.missing: script ubuntu/3.sh not found",
		"ubuntu/9.sh: script is not listed in controls.yaml",
		"iosxe/7.sh:2: use FAIL, not FAILED",
	} {
		if !strings.Contains(joined, want) {
			t.Errorf("missing problem %q in:\n%s", want, joined)
		}
	}
	if strings.Contains(joined, "ubuntu/1.sh") {
		t.Errorf("clean script reported:\n%s", joined)
	}
}

func TestEndsWithExit(t *testing.T) {
	lines := func(src string) []line {
		var out []line
		for i, t := range strings.Split(src, "\n") {
			if s := strings.TrimSpace(t); s != "" && !strings.HasPrefix(s, "#") {
				out = append(out, line{i + 1, t})
			}
		}
		return out
	}
	if !endsWithExit(lines("if a; then\n echo \"PASS: x\"\n exit 0\nelse\n echo \"FAIL: y\"\n exit 1\nfi"), false) {
		t.Error("if/else with exits in both branches should count as ending with exit")
	}
	if endsWithExit(lines("if a; then\n echo \"FAIL: y\"\n exit 1\nfi"), false) {
		t.Error("if without else can fall through")
	}
}
