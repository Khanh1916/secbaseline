package runner

import (
	"os"
	"strings"
)

func platformInfo() (platform, version, kernel string) {
	if data, err := os.ReadFile("/etc/os-release"); err == nil {
		for _, l := range strings.Split(string(data), "\n") {
			k, v, _ := strings.Cut(l, "=")
			v = strings.Trim(v, `"'`)
			switch k {
			case "ID":
				platform = v
			case "VERSION_ID":
				version = v
			}
		}
	}
	if data, err := os.ReadFile("/proc/sys/kernel/osrelease"); err == nil {
		kernel = strings.TrimSpace(string(data))
	}
	return platform, version, kernel
}
