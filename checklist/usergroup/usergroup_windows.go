package usergroup

import (
	"fmt"
	"os/exec"
	"slices"
	"strings"
)

func GetUsersAndGroups() (string, error) {
	groups, err := getLocalGroups()
	if err != nil {
		return "", fmt.Errorf("failed to get local groups: %v", err)
	}

	if len(groups) == 0 {
		return "", fmt.Errorf("no groups found")
	}

	userGroups := make(map[string][]string)

	// Iterate through each group and get its members
	for _, group := range groups {
		members, err := getGroupMembers(group)
		if err != nil {
			continue // Skip groups that can't be read
		}

		// Add each member to the userGroups map
		for _, user := range members {
			// Clean up the username
			user = strings.TrimSpace(user)
			if user != "" {
				userGroups[user] = append(userGroups[user], group)
			}
		}
	}

	if len(userGroups) == 0 {
		return "", fmt.Errorf("no users found in any groups")
	}

	// Build the result string
	var result strings.Builder
	users := make([]string, 0, len(userGroups))
	for user := range userGroups {
		users = append(users, user)
	}
	slices.Sort(users)

	for _, user := range users {
		groups := userGroups[user]
		slices.Sort(groups)
		result.WriteString(fmt.Sprintf(`"%s": %s`+"\n", user, strings.Join(groups, ", ")))
	}

	return result.String(), nil
}

// get all local groups
func getLocalGroups() ([]string, error) {
	cmd := exec.Command("net", "localgroup")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to run net localgroup: %v", err)
	}

	lines := strings.Split(string(output), "\n")
	var groups []string
	inGroupSection := false

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)

		// Look for the separator line that indicates start of groups list
		if strings.Contains(trimmed, "----") || strings.Contains(trimmed, "====") {
			inGroupSection = true
			continue
		}

		if inGroupSection {
			// Stop when we hit completion message
			if strings.Contains(trimmed, "The command completed") ||
				strings.Contains(trimmed, "successfully") {
				break
			}

			// Skip empty lines and header lines
			if trimmed != "" &&
				!strings.Contains(trimmed, "Group Accounts") &&
				!strings.Contains(trimmed, "Aliases") &&
				trimmed != "*" {
				// Remove the leading * from group names
				groupName := strings.TrimPrefix(trimmed, "*")
				groups = append(groups, groupName)
			}
		}
	}

	return groups, nil
}

// get members of a specific group
func getGroupMembers(groupName string) ([]string, error) {
	cmd := exec.Command("net", "localgroup", groupName)
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to get members of group %s: %v", groupName, err)
	}

	lines := strings.Split(string(output), "\n")
	var members []string
	inMemberSection := false

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)

		// Look for the separator line that indicates start of members list
		if strings.Contains(trimmed, "----") || strings.Contains(trimmed, "====") {
			inMemberSection = true
			continue
		}

		if inMemberSection {
			// Stop when we hit completion message
			if strings.Contains(trimmed, "The command completed") ||
				strings.Contains(trimmed, "successfully") {
				break
			}

			// Skip empty lines and header lines
			if trimmed != "" &&
				!strings.Contains(trimmed, "Members") &&
				!strings.Contains(trimmed, "Alias name") &&
				trimmed != "*" {
				members = append(members, trimmed)
			}
		}
	}

	return members, nil
}
