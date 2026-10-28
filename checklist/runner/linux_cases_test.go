package runner

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"testing"
	"time"

	"checklist/catalog"
)

// Linux host checks are tested in containers of the distribution they target.
// A case is a setup script, <platform>/testdata/<id>/pass-<case>.sh or
// fail-<case>.sh, that brings a fresh container into a compliant or a
// non-compliant state; the check must then give the verdict the file name
// starts with. Setup scripts run as root after checklist/runner/testdata/
// linux-setup.sh, which provides helpers such as pkg_install; a setup that
// exits 77 skips its case (for example a package missing from the image's
// repositories).
//
// Platforms whose scripts are copies of another platform's use that
// platform's cases for every control without a testdata directory of its own.
var caseSource = map[string]string{
	"debian":      "ubuntu",
	"rocky":       "redhat",
	"centos":      "redhat",
	"oraclelinux": "redhat",
	"suse":        "redhat",
}

// notCovered lists the controls that have no cases, and why: their verdict
// depends on state that a container shares with, or cannot get from, the host.
var notCovered = map[string]string{
	"linux.filesystem.cramfs_disabled":      "kernel modules belong to the host kernel: lsmod shows the host's modules and the container has none on disk",
	"linux.filesystem.squashfs_disabled":    "kernel modules belong to the host kernel: lsmod shows the host's modules and the container has none on disk",
	"linux.filesystem.udf_disabled":         "kernel modules belong to the host kernel: lsmod shows the host's modules and the container has none on disk",
	"linux.hardening.core_dumps_restricted": "reads the core size limit of its own process, which comes from the container runtime",
	"linux.hardening.aslr_enabled":          "kernel.randomize_va_space is a host kernel setting, not namespaced",
	"linux.time.clock_synchronized":         "needs systemd-timedated and a synchronized clock",
}

// caseFile is one setup script and the check it is run against.
type caseFile struct {
	key, id, path, want string
}

// linuxCases returns the cases of every control of a Linux platform, by
// control key. Paths are relative to the repository root.
func linuxCases(cat *catalog.Catalog, platform string) (map[string][]caseFile, error) {
	out := map[string][]caseFile{}
	for _, it := range cat.ControlsFor(platform) {
		id := strconv.Itoa(it.IDs[platform])
		dir := filepath.Join(platform, "testdata", id)
		if _, err := os.Stat(filepath.Join(cat.Root, dir)); err != nil {
			src, ok := caseSource[platform]
			srcID, has := it.IDs[src]
			if !ok || !has {
				continue
			}
			dir = filepath.Join(src, "testdata", strconv.Itoa(srcID))
		}
		files, err := filepath.Glob(filepath.Join(cat.Root, dir, "*.sh"))
		if err != nil {
			return nil, err
		}
		for _, f := range files {
			name := filepath.Base(f)
			want, _, _ := strings.Cut(name, "-")
			if want != StatusPass && want != StatusFail {
				return nil, fmt.Errorf("%s: case name must start with pass- or fail-", filepath.Join(dir, name))
			}
			out[it.Key] = append(out[it.Key], caseFile{
				key: it.Key, id: id, want: want,
				path: filepath.ToSlash(filepath.Join(dir, name)),
			})
		}
	}
	return out, nil
}

func loadCatalog(t *testing.T) *catalog.Catalog {
	t.Helper()
	root, err := filepath.Abs(filepath.Join("..", ".."))
	if err != nil {
		t.Fatal(err)
	}
	cat, err := catalog.Load(root)
	if err != nil {
		t.Fatal(err)
	}
	return cat
}

// TestLinuxCaseCoverage keeps notCovered honest: every Linux control has
// cases on every platform, or is listed there, but not both.
func TestLinuxCaseCoverage(t *testing.T) {
	cat := loadCatalog(t)
	for _, platform := range cat.PlatformNames() {
		if cat.Platforms[platform].Kind != catalog.KindLinux {
			continue
		}
		cases, err := linuxCases(cat, platform)
		if err != nil {
			t.Fatal(err)
		}
		for _, it := range cat.ControlsFor(platform) {
			_, skip := notCovered[it.Key]
			switch has := len(cases[it.Key]) > 0; {
			case has && skip:
				t.Errorf("%s/%d (%s) has cases but is listed in notCovered", platform, it.IDs[platform], it.Key)
			case !has && !skip:
				t.Errorf("%s/%d (%s) has no cases", platform, it.IDs[platform], it.Key)
			}
		}
	}
	for key := range notCovered {
		if !cat.HasKey(key) {
			t.Errorf("notCovered lists unknown control %s", key)
		}
	}
}

// TestLinuxCases runs every case of one platform in its distribution's image:
//
//	CHECKLIST_CASES_PLATFORM=ubuntu CHECKLIST_CASES_IMAGE=ubuntu:24.04 \
//	  go test -count=1 -timeout 60m -run TestLinuxCases ./runner
//
// It needs Docker and runs each case in a new privileged container, so that
// setups can mount filesystems, set network sysctls and load firewall rules
// in the container's own namespaces. -run TestLinuxCases/<key> selects cases.
func TestLinuxCases(t *testing.T) {
	platform, image := os.Getenv("CHECKLIST_CASES_PLATFORM"), os.Getenv("CHECKLIST_CASES_IMAGE")
	if platform == "" || image == "" {
		t.Skip("set CHECKLIST_CASES_PLATFORM and CHECKLIST_CASES_IMAGE to run the Linux cases in Docker")
	}
	cat := loadCatalog(t)
	if p, ok := cat.Platforms[platform]; !ok || p.Kind != catalog.KindLinux {
		t.Fatalf("%s is not a Linux platform", platform)
	}
	cases, err := linuxCases(cat, platform)
	if err != nil {
		t.Fatal(err)
	}
	runImage := caseImage(t, cat, platform, image)

	keys := make([]string, 0, len(cases))
	for k := range cases {
		keys = append(keys, k)
	}
	slices.Sort(keys)
	for _, key := range keys {
		for _, c := range cases[key] {
			name := key + "/" + strings.TrimSuffix(filepath.Base(c.path), ".sh")
			t.Run(name, func(t *testing.T) {
				t.Parallel()
				runCase(t, runImage, platform, c)
			})
		}
	}
}

const caseRoot = "/opt/secbaseline"

func runCase(t *testing.T, image, platform string, c caseFile) {
	script := fmt.Sprintf(`set -e
cd %[1]s
(. checklist/runner/testdata/linux-setup.sh; . %[2]s) >&2
checklist run --root %[1]s -p %[3]s --only %[4]s --no-collectors -o /tmp/case.json >&2
cat /tmp/case.json`, caseRoot, c.path, platform, c.key)
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Minute)
	defer cancel()
	cmd := exec.CommandContext(ctx, "docker", "run", "--rm", "--privileged", image, "bash", "-c", script)
	var stdout, stderr bytes.Buffer
	cmd.Stdout, cmd.Stderr = &stdout, &stderr
	err := cmd.Run()
	var exitErr *exec.ExitError
	switch {
	case errors.As(err, &exitErr) && exitErr.ExitCode() == 77:
		t.Skipf("setup skipped the case: %s", lastLines(stderr.String(), 3))
	case err != nil:
		t.Fatalf("%s: %v\n%s", c.path, err, lastLines(stderr.String(), 40))
	}
	var rep Report
	if err := json.Unmarshal(stdout.Bytes(), &rep); err != nil {
		t.Fatalf("%s: report: %v\n%s", c.path, err, lastLines(stderr.String(), 40))
	}
	if len(rep.Checks) != 1 {
		t.Fatalf("%s: ran %d checks, want 1", c.path, len(rep.Checks))
	}
	if r := rep.Checks[0]; r.Status != c.want {
		detail := strings.Join(r.Details, "\n  ")
		if detail != "" {
			detail = "\n  " + detail
		}
		t.Errorf("%s/%s: status %s, want %s: %s%s%s", platform, r.ID, r.Status, c.want, r.Message, r.Error, detail)
	}
}

// caseImage returns an image with the distribution's usual host tools, the
// checklist binary, the catalog and the platform's scripts and cases. The
// prepared base (tools and package metadata) is cached by content.
func caseImage(t *testing.T, cat *catalog.Catalog, platform, image string) string {
	t.Helper()
	prepare, err := os.ReadFile(filepath.Join("testdata", "linux-prepare.sh"))
	if err != nil {
		t.Fatal(err)
	}
	sum := sha256.Sum256(append([]byte(image+"\n"), prepare...))
	base := "secbaseline-cases:" + platform + "-" + hex.EncodeToString(sum[:6])
	if exec.Command("docker", "image", "inspect", base).Run() != nil {
		name := "secbaseline-prepare-" + strconv.Itoa(os.Getpid())
		cmd := exec.Command("docker", "run", "-i", "--name", name, image, "bash", "-s")
		cmd.Stdin = bytes.NewReader(prepare)
		if out, err := cmd.CombinedOutput(); err != nil {
			exec.Command("docker", "rm", "-f", name).Run()
			t.Fatalf("preparing %s: %v\n%s", image, err, lastLines(string(out), 40))
		}
		docker(t, "commit", name, base)
		docker(t, "rm", name)
	}

	arch := strings.TrimSpace(docker(t, "version", "--format", "{{.Server.Arch}}"))
	stage := t.TempDir()
	bin := filepath.Join(stage, "bin", "checklist")
	build := exec.Command("go", "build", "-o", bin, ".")
	build.Dir = ".."
	build.Env = append(os.Environ(), "GOOS=linux", "GOARCH="+arch, "CGO_ENABLED=0")
	if out, err := build.CombinedOutput(); err != nil {
		t.Fatalf("building checklist: %v\n%s", err, out)
	}

	tree := filepath.Join(stage, "tree")
	files := []string{catalog.FileName, platform, filepath.Join("checklist", "runner", "testdata", "linux-setup.sh")}
	if src, ok := caseSource[platform]; ok {
		files = append(files, filepath.Join(src, "testdata"))
	}
	for _, f := range files {
		if err := copyTree(filepath.Join(cat.Root, f), filepath.Join(tree, f)); err != nil {
			t.Fatal(err)
		}
	}

	name := "secbaseline-cases-" + strconv.Itoa(os.Getpid())
	run := "secbaseline-cases:" + platform + "-run-" + strconv.Itoa(os.Getpid())
	docker(t, "create", "--name", name, base)
	defer exec.Command("docker", "rm", "-f", name).Run()
	docker(t, "cp", tree+string(filepath.Separator)+".", name+":"+caseRoot)
	docker(t, "cp", bin, name+":/usr/local/bin/checklist")
	docker(t, "commit", name, run)
	t.Cleanup(func() { exec.Command("docker", "rmi", "-f", run).Run() })
	return run
}

func docker(t *testing.T, args ...string) string {
	t.Helper()
	out, err := exec.Command("docker", args...).CombinedOutput()
	if err != nil {
		t.Fatalf("docker %s: %v\n%s", strings.Join(args, " "), err, out)
	}
	return string(out)
}

// copyTree copies a file or a directory tree, keeping LF line endings as they are.
func copyTree(src, dst string) error {
	return filepath.WalkDir(src, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(src, path)
		target := filepath.Join(dst, rel)
		if d.IsDir() {
			return os.MkdirAll(target, 0o755)
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
			return err
		}
		return os.WriteFile(target, data, 0o644)
	})
}

func lastLines(s string, n int) string {
	lines := strings.Split(strings.TrimRight(s, "\n"), "\n")
	if len(lines) > n {
		lines = lines[len(lines)-n:]
	}
	return strings.Join(lines, "\n")
}
