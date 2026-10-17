package patching

import "os/exec"

func GetPatching() (string, error) {
	cmd := exec.Command("uname", "-a")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", err
	}
	return string(output), nil
}
