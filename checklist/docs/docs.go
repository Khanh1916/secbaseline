// Package docs keeps the control tables in each platform README in sync with controls.yaml.
//
// Only the text between BeginMarker and EndMarker is generated; everything else
// in a README is hand-written and left untouched.
package docs

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"checklist/catalog"
)

const (
	BeginMarker = "<!-- BEGIN GENERATED: checklist docs -->"
	EndMarker   = "<!-- END GENERATED -->"
)

// Sync rewrites the generated section of every platform README. With check set,
// nothing is written and the paths that are out of date are returned instead.
func Sync(cat *catalog.Catalog, check bool) (stale []string, err error) {
	for _, name := range cat.PlatformNames() {
		path := filepath.Join(cat.Root, name, "README.md")
		current, err := os.ReadFile(path)
		if err != nil {
			return stale, fmt.Errorf("%s: %w (create it with the two markers first)", path, err)
		}
		updated, err := splice(current, table(cat, name))
		if err != nil {
			return stale, fmt.Errorf("%s: %w", path, err)
		}
		// Compare ignoring line endings: Windows checkouts turn LF into CRLF.
		if bytes.Equal(bytes.ReplaceAll(current, []byte("\r\n"), []byte("\n")), updated) {
			continue
		}
		stale = append(stale, filepath.ToSlash(filepath.Join(name, "README.md")))
		if !check {
			if err := os.WriteFile(path, updated, 0o644); err != nil {
				return stale, err
			}
		}
	}
	return stale, nil
}

func splice(doc []byte, generated string) ([]byte, error) {
	text := strings.ReplaceAll(string(doc), "\r\n", "\n")
	begin := strings.Index(text, BeginMarker)
	end := strings.Index(text, EndMarker)
	if begin < 0 || end < begin {
		return nil, fmt.Errorf("missing %q ... %q markers", BeginMarker, EndMarker)
	}
	return []byte(text[:begin+len(BeginMarker)] + "\n" + generated + text[end:]), nil
}

func table(cat *catalog.Catalog, platform string) string {
	p := cat.Platforms[platform]
	var b strings.Builder
	controls := cat.ControlsFor(platform)
	fmt.Fprintf(&b, "\n### Controls (%d)\n\n", len(controls))
	b.WriteString("| ID | Control | Key |\n|---:|---|---|\n")
	for _, it := range controls {
		id := it.IDs[platform]
		fmt.Fprintf(&b, "| [%d](%d%s) | %s | `%s` |\n", id, id, p.Extension(), escape(it.Title), it.Key)
	}
	if collectors := cat.CollectorsFor(platform); len(collectors) > 0 {
		fmt.Fprintf(&b, "\n### Inventory collectors (%d)\n\n", len(collectors))
		b.WriteString("Served by the Go binary: `checklist <id>`.\n\n| ID | Collects | Key |\n|---:|---|---|\n")
		for _, it := range collectors {
			fmt.Fprintf(&b, "| %d | %s | `%s` |\n", it.IDs[platform], escape(it.Title), it.Key)
		}
	}
	b.WriteString("\n")
	return b.String()
}

func escape(s string) string { return strings.ReplaceAll(s, "|", `\|`) }
