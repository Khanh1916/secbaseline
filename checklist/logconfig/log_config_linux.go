package logconfig

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
)

var filesToCheck = []string{
	"/etc/bashrc",
	"/etc/bash.bashrc",
	"/etc/profile",
}

func GetLogConfig() (string, error) {
	var result string
	result += "----------SIEM----------\n"
	result += getBashrc()
	result += getRsyslogConfig()
	result += getRsyslogStatus()
	result += "\n----------Kaspersky----------\n"
	result += getKasperskyStatus()
	return result, nil
}

func getBashrc() string {
	var result string
	for _, file := range filesToCheck {
		f, err := os.Open(file)
		if err != nil {
			continue
		}
		defer f.Close()

		found := map[string]bool{
			"export HISTSIZE=50000":                false,
			"export HISTORY=50000":                 false,
			`export HISTTIMEFORMAT="%d/%m/%y %T "`: false,
			`export PROMPT_COMMAND='RETRN_VAL=0;logger -p local6.debug"[CMDLOG] [$USER:$PWD] [$(echo $SSH_CLIENT | cut -d" " -f1)]# $(history 1 )"'`: false,
		}
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			line := scanner.Text()
			if _, ok := found[line]; ok {
				found[line] = true
			}
		}
		if err = scanner.Err(); err != nil {
			continue
		}
		result += fmt.Sprintf("****%s****\n", file)
		for fd, ok := range found {
			if ok {
				result += fmt.Sprintf("+ %s\n", fd)
			} else {
				result += fmt.Sprintf("- %s\n", fd)
			}
		}
	}
	return result
}

func getRsyslogConfig() string {
	result := "****/etc/rsyslog.conf****\n"
	f, err := os.Open("/etc/rsyslog.conf")
	if err != nil {
		return result
	}
	defer f.Close()

	found := map[string]bool{
		"local6.* /var/log/cmdlog.log": false,
	}
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		if _, ok := found[line]; ok {
			found[line] = true
		}
	}
	if err = scanner.Err(); err != nil {
		return result
	}

	for fd, ok := range found {
		if ok {
			result += fmt.Sprintf("+%s\n", fd)
		} else {
			result += fmt.Sprintf("-%s\n", fd)
		}
	}
	return result
}

func getRsyslogStatus() string {
	result := "****systemctl status rsyslog****\n"
	cmd := exec.Command("systemctl", "status", "rsyslog")
	output, _ := cmd.CombinedOutput()
	result += fmt.Sprintf("%s\n", string(output))
	return result
}

func getKasperskyStatus() string {
	result := ""
	cmd := exec.Command("systemctl", "status", "kesl.service")
	output, _ := cmd.CombinedOutput()
	result += fmt.Sprintf("%s\n", string(output))
	return result
}
