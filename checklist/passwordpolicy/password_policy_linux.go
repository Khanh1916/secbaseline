package passwordpolicy

import (
	"bufio"
	"os"
	"slices"
	"strings"
)

var (
	policyKey = map[string]struct{}{
		"PASS_MIN_LEN":  {},
		"PASS_MAX_DAYS": {},
		"PASS_WARN_AGE": {},
	}
)

func GetPasswordPolicy() (string, error) {
	loginPolicy, err := getLoginPolicy()
	if err != nil {
		return "", err
	}
	slices.Sort(loginPolicy)
	pamPolicy, err := getPAMPolicy()
	if err != nil {
		return "", err
	}
	slices.Sort(pamPolicy)
	policies := append(loginPolicy, pamPolicy...)
	return strings.Join(policies, "\n"), nil
}

func getLoginPolicy() ([]string, error) {
	file, err := os.Open("/etc/login.defs")
	if err != nil {
		return nil, err
	}
	defer file.Close()

	result := make([]string, 0)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "#") || strings.TrimSpace(line) == "" {
			continue
		}
		parts := strings.Fields(line)
		if len(parts) >= 2 {
			key := parts[0]
			if _, ok := policyKey[key]; ok {
				result = append(result, line)
			}
		}
	}

	if err = scanner.Err(); err != nil {
		return nil, err
	}

	return result, nil
}

func getPAMPolicy() ([]string, error) {
	var pamPolicyFile string
	if fileExists("/etc/pam.d/common-password") {
		pamPolicyFile = "/etc/pam.d/common-password"
	} else if fileExists("/etc/pam.d/system-auth") {
		pamPolicyFile = "/etc/pam.d/system-auth"
	}
	file, err := os.Open(pamPolicyFile)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	result := make([]string, 0)
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		// Bỏ qua comment và dòng rỗng
		if strings.HasPrefix(line, "#") || strings.TrimSpace(line) == "" {
			continue
		}
		result = append(result, line)
	}

	if err = scanner.Err(); err != nil {
		return nil, err
	}

	return result, nil
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && !info.IsDir()
}
