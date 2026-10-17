package runner

import (
	"fmt"

	"golang.org/x/sys/windows/registry"
)

func platformInfo() (platform, version, kernel string) {
	k, err := registry.OpenKey(registry.LOCAL_MACHINE, `SOFTWARE\Microsoft\Windows NT\CurrentVersion`, registry.QUERY_VALUE)
	if err != nil {
		return "windows", "", ""
	}
	defer k.Close()
	platform, _, _ = k.GetStringValue("ProductName")
	version, _, _ = k.GetStringValue("DisplayVersion")
	build, _, _ := k.GetStringValue("CurrentBuild")
	ubr, _, _ := k.GetIntegerValue("UBR")
	if build != "" {
		kernel = fmt.Sprintf("10.0.%s.%d", build, ubr)
	}
	return platform, version, kernel
}
