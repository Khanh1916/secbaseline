package usergroup

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strings"

	"github.com/thoas/go-funk"
)

const (
	sudoGroupName = "sudo"
)

type User struct {
	GID    string
	Groups []string
}

func GetUsersAndGroups() (string, error) {
	userInfos, users, err := getUsers()
	if err != nil {
		return "", err
	}
	sudoGroups, err := getGroupsWithSudoPrivileges()
	if err != nil {
		return "", err
	}

	if err = getUserGroups(userInfos, sudoGroups); err != nil {
		return "", err
	}

	slices.Sort(users)
	var result string
	for _, user := range users {
		userInfo, ok := userInfos[user]
		if !ok {
			continue
		}
		groups := funk.UniqString(userInfo.Groups)
		slices.Sort(groups)
		result += fmt.Sprintf("\"%s\": %s\n", user, strings.Join(groups, ", "))
	}
	return result, nil
}

func getUsers() (map[string]*User, []string, error) {
	userInfos := make(map[string]*User)
	users := make([]string, 0)

	f, err := os.Open("/etc/passwd")
	if err != nil {
		return nil, nil, err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, ":")
		if len(parts) < 7 {
			continue
		}
		username := parts[0]
		gid := parts[3]
		userInfos[username] = &User{
			GID:    gid,
			Groups: []string{},
		}
		users = append(users, username)
	}

	if err = scanner.Err(); err != nil {
		return nil, nil, err
	}

	return userInfos, users, nil
}

func getUserGroups(users map[string]*User, sudoGroups map[string]struct{}) error {
	f, err := os.Open("/etc/group")
	if err != nil {
		return err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, ":")
		if len(parts) < 4 {
			continue
		}
		groupName := parts[0]
		gid := parts[2]
		members := strings.Split(parts[3], ",")
		var isSudoGroup bool
		if _, ok := sudoGroups[groupName]; ok {
			isSudoGroup = true
		}

		for _, user := range users {
			if user.GID == gid {
				user.Groups = append(user.Groups, groupName)
				if isSudoGroup {
					user.Groups = append(user.Groups, sudoGroupName)
				}
			}
		}

		for _, member := range members {
			member = strings.TrimSpace(member)
			if member == "" {
				continue
			}
			if u, ok := users[member]; ok {
				u.Groups = append(u.Groups, groupName)
				if isSudoGroup {
					u.Groups = append(u.Groups, sudoGroupName)
				}
			}
		}
	}
	if err = scanner.Err(); err != nil {
		return err
	}
	return nil
}

func getGroupsWithSudoPrivileges() (map[string]struct{}, error) {
	file, err := os.Open("/etc/sudoers")
	if err != nil {
		return nil, nil
	}
	defer file.Close()

	sudoGroups := make(map[string]struct{})
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		// Skip comments
		if strings.HasPrefix(line, "#") {
			continue
		}

		// Find lines starting with %groupname
		if strings.HasPrefix(line, "%") {
			fields := strings.Fields(line)
			if len(fields) >= 2 && strings.Contains(fields[1], "ALL") {
				group := strings.TrimPrefix(fields[0], "%")
				sudoGroups[group] = struct{}{}
			}
		}
	}
	if err = scanner.Err(); err != nil {
		return nil, err
	}

	return sudoGroups, nil
}
