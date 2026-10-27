// Package collector maps collector IDs to the inventory functions that serve them.
package collector

import (
	"fmt"
	"slices"

	"checklist/account"
	"checklist/file"
	"checklist/filechecksum"
	"checklist/firewall"
	"checklist/logconfig"
	"checklist/passwordpolicy"
	"checklist/patching"
	"checklist/port"
	"checklist/ssh"
	"checklist/usergroup"
)

// Input carries the optional arguments some collectors need.
type Input struct {
	Files   []string
	Folders []string
}

type entry struct {
	ids []string
	run func(Input) (string, error)
}

// Each entry lists the collector's ID on every platform, in the order
// ubuntu, debian, rocky, centos, redhat, suse, oraclelinux, generic, windows.
var entries = []entry{
	{[]string{"1091", "11091", "3092", "5092", "2092", "291", "6091", "1", "4027"}, func(Input) (string, error) { return ssh.GetSSHKeys() }},
	{[]string{"1092", "11092", "3093", "5093", "2093", "292", "6092", "2", "4028"}, func(Input) (string, error) { return account.GetAccounts() }},
	{[]string{"1093", "11093", "3094", "5094", "2094", "293", "6093", "3", "4029"}, func(Input) (string, error) { return usergroup.GetUsersAndGroups() }},
	{[]string{"1094", "11094", "3095", "5095", "2095", "294", "6094", "4", "4030"}, func(Input) (string, error) { return passwordpolicy.GetPasswordPolicy() }},
	{[]string{"1095", "11095", "3096", "5096", "2096", "295", "6095", "5", "4031"}, func(Input) (string, error) { return patching.GetPatching() }},
	{[]string{"1096", "11096", "3097", "5097", "2097", "296", "6096", "6", "4032"}, func(in Input) (string, error) { return filechecksum.Checksums(in.Files), nil }},
	{[]string{"1097", "11097", "3098", "5098", "2098", "297", "6097", "7", "4033"}, func(in Input) (string, error) { return file.Files(in.Folders), nil }},
	{[]string{"1098", "11098", "3099", "5099", "2099", "298", "6098", "8", "4034"}, func(Input) (string, error) { return port.GetPorts() }},
	{[]string{"1099", "11099", "3100", "5100", "2100", "299", "6099", "9", "4035"}, func(Input) (string, error) { return firewall.GetRules() }},
	{[]string{"1100", "11100", "3101", "5101", "2101", "300", "6100", "10", "4036"}, func(Input) (string, error) { return logconfig.GetLogConfig() }},
}

// Known reports whether id is served by a collector.
func Known(id string) bool {
	for _, e := range entries {
		if slices.Contains(e.ids, id) {
			return true
		}
	}
	return false
}

// Run executes the collector registered for id.
func Run(id string, in Input) (string, error) {
	for _, e := range entries {
		if slices.Contains(e.ids, id) {
			return e.run(in)
		}
	}
	return "", fmt.Errorf("invalid id: %s", id)
}
