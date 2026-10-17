package patching

import (
	"bytes"
	"fmt"
	"log/slog"
	"os/exec"
	"strings"
)

func GetPatching() (string, error) {
	psScript := fmt.Sprintf(`
	$latestHotfix = Get-HotFix | Sort-Object {
		[int]($_.HotFixID -replace 'KB', '')
	} -Descending | Select-Object -First 1
	
	Write-Output "Source: $($latestHotfix.PsComputerName)"
	Write-Output "HotFixID: $($latestHotfix.HotFixID)"
	Write-Output "InstalledOn: $($latestHotfix.InstalledOn)"
	`)
	cmd := exec.Command("powershell", "-Command", psScript)
	slog.Debug("Patching get raw patching versions", "cmd", cmd.String())

	var errBuf bytes.Buffer
	cmd.Stderr = &errBuf
	out, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("get patching versions failed: stderr: %v, err: %v", errBuf.String(), err)
	}
	return strings.TrimSpace(string(out)), nil
}
