package file

import (
	"os"
	"path/filepath"
	"slices"
	"strings"

	"github.com/thoas/go-funk"
)

func Files(folders []string) string {
	slices.Sort(folders)
	folders = funk.UniqString(folders)
	allFiles := make([]string, 0, 10)
	for _, folder := range folders {
		files := getFiles(folder)
		slices.Sort(files)
		allFiles = append(allFiles, files...)

	}
	return strings.Join(allFiles, "\n")
}

func getFiles(folder string) []string {
	entry, err := os.ReadDir(folder)
	if err != nil {
		return nil
	}
	var files []string
	for _, e := range entry {
		if e.IsDir() {
			continue
		}
		fullPath := filepath.Join(folder, e.Name())
		files = append(files, fullPath)
	}
	return files
}
