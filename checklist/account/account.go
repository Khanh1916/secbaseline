package account

import (
	"bufio"
	"bytes"
	"os"
	"os/exec"
	"runtime"
	"slices"
	"strings"
)

func GetAccounts() (string, error) {
	var (
		results []string
		err     error
	)
	switch runtime.GOOS {
	case "linux":
		results, err = getAccountsLinux()
	case "windows":
		results, err = getAccountsWindows()
	}
	if err != nil {
		return "", err
	}
	slices.Sort(results)
	return strings.Join(results, ", "), nil
}

func getAccountsLinux() ([]string, error) {
	file, err := os.Open("/etc/passwd")
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var users []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, ":")
		if len(parts) >= 1 {
			users = append(users, parts[0])
		}
	}

	if scanner.Err() != nil {
		return nil, scanner.Err()
	}

	return users, nil
}

func getAccountsWindows() ([]string, error) {
	cmd := exec.Command("powershell", "-Command", "Get-LocalUser | Select-Object -ExpandProperty Name")
	var out bytes.Buffer
	cmd.Stdout = &out
	err := cmd.Run()
	if err != nil {
		return nil, err
	}

	lines := strings.Split(out.String(), "\n")
	var users []string
	for _, line := range lines {
		name := strings.TrimSpace(line)
		if name != "" {
			users = append(users, name)
		}
	}

	return users, nil
}
