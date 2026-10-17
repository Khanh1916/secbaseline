package filechecksum

import (
	"crypto/sha256"
	"fmt"
	"io"
	"os"
	"slices"

	"github.com/thoas/go-funk"
)

func Checksums(files []string) string {
	slices.Sort(files)
	files = funk.UniqString(files)
	var result string
	for _, file := range files {
		checksum, err := calculateSHA256(file)
		if err != nil {
			continue
		} else {
			result += fmt.Sprintf("\"%s\": %s\n", file, checksum)
		}
	}
	return result
}

func calculateSHA256(filePath string) (string, error) {
	f, err := os.Open(filePath)
	if err != nil {
		return "", err
	}
	defer f.Close()

	hasher := sha256.New()
	if _, err := io.Copy(hasher, f); err != nil {
		return "", err
	}

	return fmt.Sprintf("%x", hasher.Sum(nil)), nil
}
