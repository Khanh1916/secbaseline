package logconfig

import (
	"fmt"
	"os/exec"
)

func GetLogConfig() (string, error) {
	var result string
	result += "----------SIEM----------\n"
	result += getScsmService()
	result += getAVPService()
	return result, nil
}

func getScsmService() string {
	result := "****Get-Service -Name scsm****\n"
	cmd := exec.Command("powershell", "-Command", "Get-Service -Name scsm")
	output, _ := cmd.CombinedOutput()
	result += fmt.Sprintf("%s\n", string(output))
	return result
}

func getAVPService() string {
	result := "****Get-Service -Name avp****\n"
	cmd := exec.Command("powershell", "-Command", `Get-Service -Name "AVP*" | Select-Object Status, Name, DisplayName`)
	output, _ := cmd.CombinedOutput()
	result += fmt.Sprintf("%s\n", string(output))
	return result
}
