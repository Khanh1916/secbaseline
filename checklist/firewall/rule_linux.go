package firewall

import (
	"fmt"
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
	cmd := exec.Command("sudo", cmdStr, "-t", table, "-vL", "-n", "--line-numbers")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("failed to get rule: %w", err)
	}
	return string(output), nil
}
