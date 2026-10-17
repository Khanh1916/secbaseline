// Package catalog loads controls.yaml, the index of every check and collector.
package catalog

import (
	"cmp"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strconv"
	"strings"

	"gopkg.in/yaml.v3"
)

// FileName is the catalog's file name at the repository root.
const FileName = "controls.yaml"

// Platform kinds. They decide how a platform's scripts are executed.
const (
	KindLinux   = "linux"
	KindWindows = "windows"
	KindNetwork = "network"
)

type Platform struct {
	Kind   string   `yaml:"kind"`
	Name   string   `yaml:"name"`
	Detect []string `yaml:"detect"`
}

// Extension is the script file extension used by platforms of this kind.
func (p Platform) Extension() string {
	if p.Kind == KindWindows {
		return ".ps1"
	}
	return ".sh"
}

type Item struct {
	Key   string         `yaml:"key"`
	Title string         `yaml:"title"`
	Needs string         `yaml:"needs"`
	IDs   map[string]int `yaml:"ids"`
}

// Section is the middle part of a three-part key ("linux.ssh.x" -> "ssh"),
// or the first part for two-part keys ("network.hostname" -> "network").
func (it Item) Section() string {
	parts := strings.Split(it.Key, ".")
	if len(parts) >= 3 {
		return parts[1]
	}
	return parts[0]
}

type Catalog struct {
	Version    int                 `yaml:"version"`
	Platforms  map[string]Platform `yaml:"platforms"`
	Controls   []Item              `yaml:"controls"`
	Collectors []Item              `yaml:"collectors"`

	// Root is the directory that holds the catalog and the platform directories.
	Root string `yaml:"-"`
}

// Load reads the catalog in root.
func Load(root string) (*Catalog, error) {
	data, err := os.ReadFile(filepath.Join(root, FileName))
	if err != nil {
		return nil, err
	}
	var c Catalog
	if err := yaml.Unmarshal(data, &c); err != nil {
		return nil, fmt.Errorf("parse %s: %w", FileName, err)
	}
	c.Root = root
	return &c, nil
}

// FindRoot returns the first of the candidate directories that contains the catalog.
func FindRoot(candidates ...string) (string, error) {
	for _, dir := range candidates {
		if dir == "" {
			continue
		}
		if _, err := os.Stat(filepath.Join(dir, FileName)); err == nil {
			abs, err := filepath.Abs(dir)
			if err != nil {
				return dir, nil
			}
			return abs, nil
		}
	}
	return "", errors.New(FileName + " not found; run from the repository root or pass --root")
}

// Platform returns the named platform or an error listing the valid names.
func (c *Catalog) Platform(name string) (Platform, error) {
	p, ok := c.Platforms[name]
	if !ok {
		return Platform{}, fmt.Errorf("unknown platform %q (valid: %s)", name, strings.Join(c.PlatformNames(), ", "))
	}
	return p, nil
}

var platformOrder = []string{"ubuntu", "debian", "redhat", "rocky", "centos", "suse", "oraclelinux", "windows", "iosxe", "junos", "iosxr", "nxos"}

// PlatformNames lists platform keys: the known platforms in a fixed order, then any others by name.
func (c *Catalog) PlatformNames() []string {
	names := make([]string, 0, len(c.Platforms))
	for n := range c.Platforms {
		names = append(names, n)
	}
	rank := func(n string) int {
		if i := slices.Index(platformOrder, n); i >= 0 {
			return i
		}
		return len(platformOrder)
	}
	slices.SortFunc(names, func(a, b string) int {
		if d := cmp.Compare(rank(a), rank(b)); d != 0 {
			return d
		}
		return strings.Compare(a, b)
	})
	return names
}

// ScriptPath is the absolute path of the script for a control on a platform.
func (c *Catalog) ScriptPath(platform string, id int) string {
	p := c.Platforms[platform]
	return filepath.Join(c.Root, platform, strconv.Itoa(id)+p.Extension())
}

// ControlsFor returns the controls that have a script on platform, in catalog order.
func (c *Catalog) ControlsFor(platform string) []Item {
	return filter(c.Controls, platform)
}

// CollectorsFor returns the collectors that have an ID on platform, in catalog order.
func (c *Catalog) CollectorsFor(platform string) []Item {
	return filter(c.Collectors, platform)
}

func filter(items []Item, platform string) []Item {
	var out []Item
	for _, it := range items {
		if _, ok := it.IDs[platform]; ok {
			out = append(out, it)
		}
	}
	return out
}
