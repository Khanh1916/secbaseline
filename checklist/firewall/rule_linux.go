package firewall

import (
	"fmt"
	"os"
	"os/exec"
)

var tables = []string{
	"filter",
	"nat",
	"mangle",
	"raw",
	"security",
}

var iptablesCMDs = []string{
	"iptables",
	"ip6tables",
}

func GetRules() (string, error) {
	var result string
	for _, iptableCMD := range iptablesCMDs {
		if iptableCMD == "iptables" {
			result += "----------v4----------\n"
		} else {
			result += "----------v6----------\n"
		}
		for _, table := range tables {
			rule, err := getRule(iptableCMD, table)
			if err != nil {
				continue
			}
			result += fmt.Sprintf("****%s****\n%s\n", table, rule)
		}
		result += "\n"
	}
	return result, nil
}

func getRule(cmdStr string, table string) (string, error) {
	args := []string{cmdStr, "-t", table, "-vL", "-n", "--line-numbers"}
	// Root runs iptables directly (containers often lack sudo). Anyone else
	// goes through sudo -n, which fails instead of waiting for a password.
	if os.Geteuid() != 0 {
		args = append([]string{"sudo", "-n"}, args...)
	}
	cmd := exec.Command(args[0], args[1:]...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("failed to get rule: %w", err)
	}
	return string(output), nil
}
