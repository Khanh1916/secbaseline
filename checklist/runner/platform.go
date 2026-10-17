package runner

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"regexp"
	"runtime"
	"slices"
	"strings"

	"checklist/catalog"
)

// DetectPlatform picks the catalog platform for the machine the runner is on.
// Linux distributions are matched by the ID field of /etc/os-release, then by ID_LIKE.
func DetectPlatform(cat *catalog.Catalog) (string, error) {
	switch runtime.GOOS {
	case "windows":
		return "windows", nil
	case "linux":
		f, err := os.Open("/etc/os-release")
		if err != nil {
			return "", fmt.Errorf("detect platform: %w; pass --platform", err)
		}
		defer f.Close()
		return matchOSRelease(cat, f)
	}
	return "", fmt.Errorf("no checks for %s; pass --platform", runtime.GOOS)
}

func matchOSRelease(cat *catalog.Catalog, r io.Reader) (string, error) {
	fields := map[string]string{}
	sc := bufio.NewScanner(r)
	for sc.Scan() {
		k, v, ok := strings.Cut(sc.Text(), "=")
		if ok {
			fields[k] = strings.ToLower(strings.Trim(v, `"'`))
		}
	}
	candidates := append([]string{fields["ID"]}, strings.Fields(fields["ID_LIKE"])...)
	for _, id := range candidates {
		for _, name := range cat.PlatformNames() {
			if slices.Contains(cat.Platforms[name].Detect, id) {
				return name, nil
			}
		}
	}
	return "", fmt.Errorf("unsupported distribution %q; pass --platform", fields["ID"])
}

var deviceHostname = []*regexp.Regexp{
	regexp.MustCompile(`(?m)^hostname\s+(\S+)`),             // IOS XE, IOS XR, NX-OS
	regexp.MustCompile(`(?m)^set system host-name\s+(\S+)`), // Junos set format
	regexp.MustCompile(`(?m)^\s*host-name\s+([^;\s]+);`),    // Junos curly format
	regexp.MustCompile(`(?m)^switchname\s+(\S+)`),           // older NX-OS
}

func parseDeviceHostname(config []byte) string {
	for _, re := range deviceHostname {
		if m := re.FindSubmatch(config); m != nil {
			return string(m[1])
		}
	}
	return ""
}

var errConfigRequired = errors.New("network platforms audit a saved device configuration; pass --config <file>")
