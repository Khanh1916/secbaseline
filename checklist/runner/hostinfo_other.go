//go:build !linux && !windows

package runner

func platformInfo() (platform, version, kernel string) {
	return "", "", ""
}
