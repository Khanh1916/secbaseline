package runner

import (
	"strings"
	"testing"

	"checklist/catalog"
)

func testCatalog() *catalog.Catalog {
	return &catalog.Catalog{Platforms: map[string]catalog.Platform{
		"ubuntu": {Kind: catalog.KindLinux, Detect: []string{"ubuntu"}},
		"redhat": {Kind: catalog.KindLinux, Detect: []string{"rhel"}},
		"suse":   {Kind: catalog.KindLinux, Detect: []string{"sles", "opensuse-leap"}},
	}}
}

func TestMatchOSRelease(t *testing.T) {
	tests := map[string]string{
		"ID=ubuntu\nVERSION_ID=\"24.04\"\n":                  "ubuntu",
		"ID=\"rhel\"\nID_LIKE=\"fedora\"\n":                  "redhat",
		"ID=\"almalinux\"\nID_LIKE=\"rhel centos fedora\"\n": "redhat", // falls back to ID_LIKE
		"ID=\"opensuse-leap\"\n":                             "suse",
	}
	for in, want := range tests {
		got, err := matchOSRelease(testCatalog(), strings.NewReader(in))
		if err != nil || got != want {
			t.Errorf("matchOSRelease(%q) = %q, %v; want %q", in, got, err, want)
		}
	}
	if _, err := matchOSRelease(testCatalog(), strings.NewReader("ID=gentoo\n")); err == nil {
		t.Error("expected an error for an unsupported distribution")
	}
}

func TestParseDeviceHostname(t *testing.T) {
	tests := map[string]string{
		"!\nhostname core-sw1\n!":                     "core-sw1",
		"set system host-name edge-fw\n":              "edge-fw",
		"system {\n    host-name jsw;\n}":             "jsw",
		"version 9.3\nswitchname n9k-leaf\n":          "n9k-leaf",
		"interface Gi0/1\n description no hostname\n": "",
	}
	for in, want := range tests {
		if got := parseDeviceHostname([]byte(in)); got != want {
			t.Errorf("parseDeviceHostname(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestSelectItems(t *testing.T) {
	items := []catalog.Item{{Key: "linux.ssh.a"}, {Key: "linux.sshd.b"}, {Key: "linux.auth.c"}, {Key: "collect.ports"}}
	got := selectItems(items, []string{"linux.ssh", "collect.ports"})
	if len(got) != 2 || got[0].Key != "linux.ssh.a" || got[1].Key != "collect.ports" {
		t.Fatalf("selectItems = %+v", got)
	}
}
