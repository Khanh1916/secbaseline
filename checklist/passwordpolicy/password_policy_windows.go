package passwordpolicy

import (
	"bytes"
	"os/exec"
	"slices"
	"strings"
)

func GetPasswordPolicy() (string, error) {
	cmd := exec.Command("powershell", "-Command", "net", "accounts")
	var out bytes.Buffer
	cmd.Stdout = &out

	if err := cmd.Run(); err != nil {
		return "", err
	}

	lines := strings.Split(out.String(), "\n")
	policies := make([]string, 0)

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || !strings.Contains(line, ":") {
			continue
		}

		policies = append(policies, line)
	}
	slices.Sort(policies)

	return strings.Join(policies, "\n"), nil
}
