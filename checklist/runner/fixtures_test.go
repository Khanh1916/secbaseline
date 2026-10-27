package runner

import (
	"context"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"

	"checklist/catalog"
)

// TestNetworkFixtures runs network checks against the small configurations in
// <platform>/testdata/<id>/. Each file is named after the verdict it must
// produce: pass-<case>.cfg or fail-<case>.cfg.
func TestNetworkFixtures(t *testing.T) {
	if _, err := exec.LookPath("bash"); err != nil {
		t.Skip("bash not found")
	}
	// Scripts run with the platform directory as working directory, so the
	// root must be absolute.
	root, err := filepath.Abs(filepath.Join("..", ".."))
	if err != nil {
		t.Fatal(err)
	}
	cat, err := catalog.Load(root)
	if err != nil {
		t.Fatal(err)
	}
	keys := map[string]string{} // "platform/id" -> control key
	for _, it := range cat.Controls {
		for platform, id := range it.IDs {
			keys[platform+"/"+strconv.Itoa(id)] = it.Key
		}
	}

	files, err := filepath.Glob(filepath.Join(cat.Root, "*", "testdata", "*", "*.cfg"))
	if err != nil {
		t.Fatal(err)
	}
	if len(files) == 0 {
		t.Fatal("no fixtures found")
	}
	for _, file := range files {
		rel, _ := filepath.Rel(cat.Root, file)
		parts := strings.Split(filepath.ToSlash(rel), "/") // platform, testdata, id, name
		platform, id, name := parts[0], parts[2], parts[3]
		t.Run(platform+"/"+id+"/"+strings.TrimSuffix(name, ".cfg"), func(t *testing.T) {
			t.Parallel()
			want, _, _ := strings.Cut(name, "-")
			if want != StatusPass && want != StatusFail {
				t.Fatalf("fixture name must start with pass- or fail-")
			}
			key, ok := keys[platform+"/"+id]
			if !ok {
				t.Fatalf("no control uses %s/%s", platform, id)
			}
			rep, err := Run(context.Background(), cat, Options{
				Platform: platform, Config: file, Only: []string{key}, Timeout: 30 * time.Second,
			})
			if err != nil {
				t.Fatal(err)
			}
			if len(rep.Checks) != 1 {
				t.Fatalf("ran %d checks, want 1", len(rep.Checks))
			}
			if c := rep.Checks[0]; c.Status != want {
				t.Errorf("%s: status %s, want %s (%s%s)", key, c.Status, want, c.Message, c.Error)
			}
		})
	}
}
