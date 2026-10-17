package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/signal"
	"path/filepath"
	"time"

	"github.com/spf13/cobra"

	"checklist/catalog"
	"checklist/collector"
	"checklist/docs"
	"checklist/lint"
	"checklist/report"
	"checklist/runner"
)

// version is set at build time with -ldflags "-X main.version=...".
var version = "dev"

var (
	folders []string
	files   []string
)

var rootCmd = &cobra.Command{
	Use:   "checklist [id]",
	Short: "Security compliance checks and inventory collection",
	Long: `checklist runs the security compliance checks in this repository and collects
host inventory.

  checklist <id>       run one inventory collector and print its output
  checklist run        run every check for a platform and write a JSON/HTML report
  checklist report     render a saved JSON report as HTML
  checklist lint       validate controls.yaml, the scripts' output contract and the READMEs
  checklist docs       regenerate the control tables in each platform README`,
	Args:          cobra.ExactArgs(1),
	SilenceUsage:  true,
	SilenceErrors: true,
	RunE: func(cmd *cobra.Command, args []string) error {
		out, err := collector.Run(args[0], collector.Input{Files: files, Folders: folders})
		if err != nil {
			return err
		}
		fmt.Println(out)
		return nil
	},
}

func init() {
	rootCmd.PersistentFlags().StringSliceVarP(&folders, "folders", "f", nil, "folders to list (file listing collector)")
	rootCmd.PersistentFlags().StringSliceVarP(&files, "files", "F", nil, "files to hash (file checksum collector)")
	rootCmd.AddCommand(runCmd(), reportCmd(), lintCmd(), docsCmd(), versionCmd())
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

// findRoot locates the repository root holding controls.yaml.
func findRoot(flag string) (string, error) {
	if flag != "" {
		return catalog.FindRoot(flag)
	}
	candidates := []string{".", ".."}
	if exe, err := os.Executable(); err == nil {
		dir := filepath.Dir(exe)
		candidates = append(candidates, dir, filepath.Dir(dir))
	}
	return catalog.FindRoot(candidates...)
}

func runCmd() *cobra.Command {
	var (
		root, platform, config, jsonOut, htmlOut, shell string
		only                                            []string
		jobs                                            int
		timeout                                         time.Duration
		noCollectors                                    bool
	)
	cmd := &cobra.Command{
		Use:   "run",
		Short: "Run every check for a platform and write a JSON (and optionally HTML) report",
		Example: `  sudo ./checklist/checklist run --html report.html
  ./checklist/checklist run --platform iosxe --config running-config.txt --html audit.html
  ./checklist/checklist run --only linux.ssh,linux.auth -o ssh-auth.json`,
		Args: cobra.NoArgs,
		RunE: func(cmd *cobra.Command, args []string) error {
			dir, err := findRoot(root)
			if err != nil {
				return err
			}
			cat, err := catalog.Load(dir)
			if err != nil {
				return err
			}
			if platform == "" {
				if config != "" {
					return fmt.Errorf("--config needs --platform (one of iosxe, junos, iosxr, nxos)")
				}
				if platform, err = runner.DetectPlatform(cat); err != nil {
					return err
				}
			}
			ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
			defer stop()
			rep, err := runner.Run(ctx, cat, runner.Options{
				Platform:   platform,
				Config:     config,
				Only:       only,
				Jobs:       jobs,
				Timeout:    timeout,
				Shell:      shell,
				Collectors: !noCollectors,
				Input:      collector.Input{Files: files, Folders: folders},
				Version:    version,
			})
			if rep == nil {
				return err
			}
			if werr := writeJSON(jsonOut, rep); werr != nil {
				return werr
			}
			if htmlOut != "" {
				if werr := writeHTML(htmlOut, rep); werr != nil {
					return werr
				}
			}
			s := rep.Summary
			fmt.Fprintf(os.Stderr, "%s: %d checks, %d passed, %d failed, %d errors (score %.1f%%)\n",
				rep.Platform.Key, s.Total, s.Pass, s.Fail, s.Error, s.Score)
			return err
		},
	}
	f := cmd.Flags()
	f.StringVar(&root, "root", "", "repository root containing controls.yaml (default: auto-detect)")
	f.StringVarP(&platform, "platform", "p", "", "platform key from controls.yaml (default: detect this host)")
	f.StringVarP(&config, "config", "c", "", "saved device configuration to audit (network platforms)")
	f.StringSliceVar(&only, "only", nil, "run only controls/collectors whose key starts with these prefixes")
	f.IntVarP(&jobs, "jobs", "j", 4, "checks to run in parallel")
	f.DurationVar(&timeout, "timeout", 2*time.Minute, "timeout per check")
	f.StringVar(&shell, "shell", "bash", "interpreter for .sh scripts")
	f.BoolVar(&noCollectors, "no-collectors", false, "skip inventory collectors")
	f.StringVarP(&jsonOut, "output", "o", "-", `JSON report path ("-" for stdout)`)
	f.StringVar(&htmlOut, "html", "", "also write an HTML report to this path")
	return cmd
}

func reportCmd() *cobra.Command {
	var htmlOut string
	cmd := &cobra.Command{
		Use:     "report <report.json>",
		Short:   "Render a JSON report from `checklist run` as HTML",
		Example: "  ./checklist/checklist report web01.json -o web01.html",
		Args:    cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			rep, err := report.LoadJSON(args[0])
			if err != nil {
				return err
			}
			return writeHTML(htmlOut, rep)
		},
	}
	cmd.Flags().StringVarP(&htmlOut, "output", "o", "report.html", "HTML output path")
	return cmd
}

func lintCmd() *cobra.Command {
	var root string
	cmd := &cobra.Command{
		Use:   "lint",
		Short: "Validate controls.yaml against the scripts and the scripts against the output contract",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, args []string) error {
			dir, err := findRoot(root)
			if err != nil {
				return err
			}
			cat, err := catalog.Load(dir)
			if err != nil {
				return err
			}
			problems := lint.Run(cat)
			for _, p := range problems {
				fmt.Println(p)
			}
			stale, err := docs.Sync(cat, true)
			if err != nil {
				return err
			}
			for _, s := range stale {
				fmt.Printf("%s: control table is out of date; run `checklist docs`\n", s)
			}
			if n := len(problems) + len(stale); n > 0 {
				return fmt.Errorf("%d problem(s)", n)
			}
			fmt.Fprintf(os.Stderr, "ok: %d controls, %d collectors\n", len(cat.Controls), len(cat.Collectors))
			return nil
		},
	}
	cmd.Flags().StringVar(&root, "root", "", "repository root containing controls.yaml (default: auto-detect)")
	return cmd
}

func docsCmd() *cobra.Command {
	var root string
	cmd := &cobra.Command{
		Use:   "docs",
		Short: "Regenerate the control tables in each platform README from controls.yaml",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, args []string) error {
			dir, err := findRoot(root)
			if err != nil {
				return err
			}
			cat, err := catalog.Load(dir)
			if err != nil {
				return err
			}
			updated, err := docs.Sync(cat, false)
			for _, u := range updated {
				fmt.Println("updated", u)
			}
			return err
		},
	}
	cmd.Flags().StringVar(&root, "root", "", "repository root containing controls.yaml (default: auto-detect)")
	return cmd
}

func versionCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print the version",
		Args:  cobra.NoArgs,
		Run:   func(cmd *cobra.Command, args []string) { fmt.Println(version) },
	}
}

func writeJSON(path string, rep *runner.Report) error {
	return writeFile(path, func(w io.Writer) error {
		enc := json.NewEncoder(w)
		enc.SetIndent("", "  ")
		return enc.Encode(rep)
	})
}

func writeHTML(path string, rep *runner.Report) error {
	return writeFile(path, func(w io.Writer) error { return report.WriteHTML(w, rep) })
}

func writeFile(path string, write func(io.Writer) error) error {
	if path == "-" || path == "" {
		return write(os.Stdout)
	}
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	if err := write(f); err != nil {
		f.Close()
		return err
	}
	return f.Close()
}
