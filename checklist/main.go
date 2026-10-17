package main

import (
	"fmt"
	"os"

	"checklist/account"
	"checklist/file"
	"checklist/filechecksum"
	"checklist/firewall"
	"checklist/logconfig"
	"checklist/passwordpolicy"
	"checklist/patching"
	"checklist/port"
	"checklist/ssh"
	"checklist/usergroup"
	"github.com/spf13/cobra"
)

var (
	folders []string
	files   []string
)

var rootCmd = &cobra.Command{
	Use:   "checklist [id]",
	Short: "Collect metadata from the server and format it as a checklist",
	Args:  cobra.ExactArgs(1),
	Run:   runChecklist,
}

func init() {
	rootCmd.Flags().StringSliceVarP(&folders, "folders", "f", []string{}, "folders to check")
	rootCmd.Flags().StringSliceVarP(&files, "files", "F", []string{}, "files to check")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func runChecklist(cmd *cobra.Command, args []string) {
	id := args[0]

	var (
		result string
		err    error
	)

	switch id {
	case "1091", "11091", "3092", "5092", "2092", "291", "1", "4027":
		result, err = ssh.GetSSHKeys()
	case "1092", "11092", "3093", "5093", "2093", "292", "2", "4028":
		result, err = account.GetAccounts()
	case "1093", "11093", "3094", "5094", "2094", "293", "3", "4029":
		result, err = usergroup.GetUsersAndGroups()
	case "1094", "11094", "3095", "5095", "2095", "294", "4", "4030":
		result, err = passwordpolicy.GetPasswordPolicy()
	case "1095", "11095", "3096", "5096", "2096", "295", "5", "4031":
		result, err = patching.GetPatching()
	case "1096", "11096", "3097", "5097", "2097", "296", "6", "4032":
		result = filechecksum.Checksums(files)
	case "1097", "11097", "3098", "5098", "2098", "297", "7", "4033":
		result = file.Files(folders)
	case "1098", "11098", "3099", "5099", "2099", "298", "8", "4034":
		result, err = port.GetPorts()
	case "1099", "11099", "3100", "5100", "2100", "299", "9", "4035":
		result, err = firewall.GetRules()
	case "1100", "11100", "3101", "5101", "2101", "300", "10", "4036":
		result, err = logconfig.GetLogConfig()
	default:
		fmt.Fprintf(os.Stderr, "Error: invalid id: %s\n", id)
		os.Exit(1)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	fmt.Println(result)
}
