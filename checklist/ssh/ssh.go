package ssh

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"slices"
	"strings"
	"sync"
)

const (
	rootUserName          = "root"
	administratorUserName = "administrator"
)

func GetSSHKeys() (string, error) {
	userPath, err := getOSSpecificPaths()
	if err != nil {
		return "", err
	}
	users := make([]string, 0)
	for userName := range userPath {
		users = append(users, userName)
	}
	slices.Sort(users)

	currentSSHKeys := getCurrentSSHKeys(userPath)
	var result string
	for _, user := range users {
		sshKeys, ok := currentSSHKeys[user]
		if !ok {
			continue
		}
		result += fmt.Sprintf("\"%s\":\n%s\n\n", user, strings.Join(sshKeys, "\n"))
	}

	return result, nil
}

func getCurrentSSHKeys(userPath map[string]string) map[string][]string {
	var mu sync.Mutex
	var wg sync.WaitGroup
	sshKeys := make(map[string][]string)
	for userName, path := range userPath {
		wg.Add(1)
		go func() {
			defer wg.Done()
			content, err := os.ReadFile(path)
			if err != nil {
				return
			}

			sshKeyByUsers := make([]string, 0)
			scanner := bufio.NewScanner(bytes.NewReader(content))
			for scanner.Scan() {
				line := scanner.Text()
				if line == "" {
					continue
				}
				sshKeyByUsers = append(sshKeyByUsers, line)
			}
			mu.Lock()
			sshKeys[userName] = sshKeyByUsers
			mu.Unlock()
		}()
	}
	wg.Wait()
	return sshKeys
}

// Add a new function to filter paths by OS
func getOSSpecificPaths() (map[string]string, error) {
	paths := make(map[string]string)
	var home string
	switch runtime.GOOS {
	case "windows":
		paths[administratorUserName] = `C:\ProgramData\ssh\administrators_authorized_keys`
		home = `C:\Users`
	case "darwin": // macOS
		paths[rootUserName] = `/var/root/.ssh/authorized_keys`
		home = "/Users"
	case "linux":
		paths[rootUserName] = `/root/.ssh/authorized_keys`
		home = "/home"
	}
	entries, err := os.ReadDir(home)
	if err != nil {
		return nil, fmt.Errorf("failed to read dir: %w", err)
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		path := filepath.Join(home, entry.Name(), ".ssh", "authorized_keys")
		if fileExists(path) {
			paths[entry.Name()] = path
		}
	}
	return paths, nil
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && !info.IsDir()
}
