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
	"checklist/drift"
	"checklist/lint"
	"checklist/policy"
	"checklist/report"
	"checklist/runner"
	"checklist/server"
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
  checklist diff       compare two reports: regressions, fixes and inventory drift
  checklist serve      dashboard that collects reports from many hosts
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
	rootCmd.AddCommand(runCmd(), reportCmd(), diffCmd(), serveCmd(), lintCmd(), docsCmd(), versionCmd())
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
		uploadURL, token                                string
		sarifOut, junitOut, csvOut                      string
		policyFile                                      string
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
			var pol *policy.Policy
			if policyFile != "" {
				if pol, err = policy.Load(policyFile, cat.HasKey); err != nil {
					return err
				}
			}
			ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
			defer stop()
			rep, err := runner.Run(ctx, cat, runner.Options{
				Policy:     pol,
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
			for _, out := range []struct{ path, format string }{
				{htmlOut, "html"}, {sarifOut, "sarif"}, {junitOut, "junit"}, {csvOut, "csv"},
			} {
				if out.path == "" {
					continue
				}
				if werr := writeFormat(out.path, out.format, rep); werr != nil {
					return werr
				}
			}
			if uploadURL != "" {
				body, merr := json.Marshal(rep)
				if merr != nil {
					return merr
				}
				if token == "" {
					token = server.TokenFromEnv()
				}
				url, uerr := server.Upload(context.Background(), uploadURL, token, body)
				if uerr != nil {
					return uerr
				}
				fmt.Fprintln(os.Stderr, "uploaded:", url)
			}
			s := rep.Summary
			waived := ""
			if s.Waived > 0 {
				waived = fmt.Sprintf(", %d waived", s.Waived)
			}
			fmt.Fprintf(os.Stderr, "%s: %d checks, %d passed, %d failed%s, %d errors (score %.1f%%)\n",
				rep.Platform.Key, s.Total, s.Pass, s.Fail, waived, s.Error, s.Score)
			if rep.Policy != nil {
				for _, w := range rep.Policy.ExpiredWaivers {
					fmt.Fprintf(os.Stderr, "warning: waiver for %s expired on %s\n", w.Key, w.Expires)
				}
			}
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
	f.StringVar(&sarifOut, "sarif", "", "also write SARIF 2.1.0 (code scanning) to this path")
	f.StringVar(&junitOut, "junit", "", "also write JUnit XML (CI test results) to this path")
	f.StringVar(&csvOut, "csv", "", "also write CSV (spreadsheets) to this path")
	f.StringVar(&policyFile, "policy", "", "policy file: which controls apply and which failures are waived")
	f.StringVar(&uploadURL, "upload", "", "send the report to a dashboard (checklist serve) at this URL")
	f.StringVar(&token, "token", "", "dashboard token (default: $CHECKLIST_SERVER_TOKEN)")
	return cmd
}

func diffCmd() *cobra.Command {
	var asJSON, exitCode bool
	cmd := &cobra.Command{
		Use:   "diff <old.json> <new.json>",
		Short: "Compare two reports: regressions, fixes and inventory changes",
		Long: `Compare two reports from checklist run. Checks are matched by key; collector
output is compared line by line, so new SSH keys, accounts, listening ports or
firewall rules show up as added lines. The reports may come from different
hosts, e.g. a golden baseline and a production server.`,
		Example: `  checklist diff baseline.json today.json
  checklist diff --exit-code yesterday.json today.json || alert "drift on web01"`,
		Args: cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			old, err := report.LoadJSON(args[0])
			if err != nil {
				return err
			}
			cur, err := report.LoadJSON(args[1])
			if err != nil {
				return err
			}
			res := drift.Compare(old, cur)
			if asJSON {
				enc := json.NewEncoder(os.Stdout)
				enc.SetIndent("", "  ")
				if err := enc.Encode(res); err != nil {
					return err
				}
			} else {
				drift.WriteText(os.Stdout, res)
			}
			if exitCode && res.HasDrift() {
				os.Exit(2)
			}
			return nil
		},
	}
	cmd.Flags().BoolVar(&asJSON, "json", false, "print the comparison as JSON")
	cmd.Flags().BoolVar(&exitCode, "exit-code", false, "exit 2 when there are regressions, other changes or inventory drift")
	return cmd
}

func serveCmd() *cobra.Command {
	var addr, dataDir, token string
	cmd := &cobra.Command{
		Use:   "serve",
		Short: "Run a dashboard that collects reports from many hosts",
		Long: `Run a small web dashboard. Hosts send reports with
  checklist run --upload http://<server>:8080 --token <token>
and the dashboard shows each host's latest score, its trend, and what changed
since its previous report. Reports are stored as JSON files under --data.

With --token (or $CHECKLIST_SERVER_TOKEN) every request needs the token: API
clients send "Authorization: Bearer <token>", browsers log in with any user name
and the token as password. Without a token the dashboard only listens on loopback.`,
		Example: `  checklist serve --data ./reports
  CHECKLIST_SERVER_TOKEN=s3cret checklist serve --listen 0.0.0.0:8080 --data /var/lib/secbaseline`,
		Args: cobra.NoArgs,
		RunE: func(cmd *cobra.Command, args []string) error {
			if token == "" {
				token = server.TokenFromEnv()
			}
			srv, err := server.New(server.Config{Addr: addr, DataDir: dataDir, Token: token, Version: version})
			if err != nil {
				return err
			}
			ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
			defer stop()
			return srv.ListenAndServe(ctx)
		},
	}
	cmd.Flags().StringVar(&addr, "listen", "127.0.0.1:8080", "address to listen on")
	cmd.Flags().StringVar(&dataDir, "data", "secbaseline-data", "directory where reports are stored")
	cmd.Flags().StringVar(&token, "token", "", "shared token required for every request (default: $CHECKLIST_SERVER_TOKEN)")
	return cmd
}

func reportCmd() *cobra.Command {
	var out, format string
	cmd := &cobra.Command{
		Use:   "report <report.json>",
		Short: "Convert a JSON report from `checklist run` to HTML, SARIF, JUnit XML or CSV",
		Example: `  ./checklist/checklist report web01.json -o web01.html
  ./checklist/checklist report web01.json -o web01.sarif
  ./checklist/checklist report web01.json --format junit -o -`,
		Args: cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			rep, err := report.LoadJSON(args[0])
			if err != nil {
				return err
			}
			if format == "" {
				format = report.FormatFor(out)
			}
			return writeFormat(out, format, rep)
		},
	}
	cmd.Flags().StringVarP(&out, "output", "o", "report.html", `output path ("-" for stdout)`)
	cmd.Flags().StringVar(&format, "format", "", "html, sarif, junit or csv (default: from the output file extension)")
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

func writeFormat(path, format string, rep *runner.Report) error {
	return writeFile(path, func(w io.Writer) error { return report.WriteFormat(w, format, rep) })
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
