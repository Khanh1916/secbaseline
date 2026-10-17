package firewall

import (
	"fmt"
	"os/exec"
)

func GetRules() (string, error) {
	cmd := exec.Command("powershell", "-Command", "netsh advfirewall firewall show rule name=all")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("failed to get rule: %w", err)
	}
	return string(output), nil
}
