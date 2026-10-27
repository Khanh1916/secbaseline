package catalog

import (
	"path/filepath"
	"testing"
)

func TestLoadRepositoryCatalog(t *testing.T) {
	c, err := Load(filepath.Join("..", ".."))
	if err != nil {
		t.Fatal(err)
	}
	if got := len(c.ControlsFor("redhat")); got != 91 {
		t.Errorf("redhat controls = %d, want 91", got)
	}
	if got := len(c.ControlsFor("ubuntu")); got != 90 {
		t.Errorf("ubuntu controls = %d, want 90", got)
	}
	if got := len(c.ControlsFor("iosxe")); got != 14 {
		t.Errorf("iosxe controls = %d, want 14", got)
	}
	if got := len(c.CollectorsFor("oraclelinux")); got != 10 {
		t.Errorf("oraclelinux collectors = %d, want 10", got)
	}
	if p := c.ScriptPath("windows", 4001); filepath.Base(p) != "4001.ps1" {
		t.Errorf("windows script path = %s", p)
	}
}

func TestSection(t *testing.T) {
	if s := (Item{Key: "linux.ssh.ssh_root_login_disabled"}).Section(); s != "ssh" {
		t.Errorf("section = %q", s)
	}
	if s := (Item{Key: "network.hostname"}).Section(); s != "network" {
		t.Errorf("section = %q", s)
	}
}
