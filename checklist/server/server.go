// Package server is a small dashboard that receives reports from `checklist run
// --upload` and shows each host's compliance score, trend and drift.
package server

import (
	"context"
	"crypto/subtle"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"html/template"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"slices"
	"strings"
	"time"

	"checklist/drift"
	"checklist/report"
	"checklist/runner"
)

//go:embed dashboard.html
var assets embed.FS

var pages = template.Must(template.New("").Funcs(template.FuncMap{
	"when":  func(t time.Time) string { return t.Local().Format("2006-01-02 15:04") },
	"delta": func(f float64) string { return fmt.Sprintf("%+.1f", f) },
	"upper": strings.ToUpper,
}).ParseFS(assets, "dashboard.html"))

const maxUpload = 32 << 20

type Config struct {
	Addr    string
	DataDir string
	Token   string
	Version string
}

type Server struct {
	cfg   Config
	store *Store
}

func New(cfg Config) (*Server, error) {
	st, err := NewStore(cfg.DataDir)
	if err != nil {
		return nil, err
	}
	return &Server{cfg: cfg, store: st}, nil
}

// ListenAndServe serves until ctx is cancelled. It refuses to listen on a
// non-loopback address without a token, since reports describe security gaps.
func (s *Server) ListenAndServe(ctx context.Context) error {
	host, _, err := net.SplitHostPort(s.cfg.Addr)
	if err != nil {
		return err
	}
	if ip := net.ParseIP(host); s.cfg.Token == "" && (ip == nil || !ip.IsLoopback()) && host != "localhost" {
		return errors.New("refusing to listen on a non-loopback address without --token")
	}
	srv := &http.Server{Addr: s.cfg.Addr, Handler: s.Handler(), ReadHeaderTimeout: 10 * time.Second}
	go func() {
		<-ctx.Done()
		shutdown, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		srv.Shutdown(shutdown)
	}()
	log.Printf("dashboard on http://%s (data: %s)", s.cfg.Addr, s.cfg.DataDir)
	if err := srv.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) { io.WriteString(w, "ok\n") })
	mux.Handle("POST /api/reports", s.auth(http.HandlerFunc(s.upload)))
	mux.Handle("GET /api/subjects", s.auth(http.HandlerFunc(s.apiSubjects)))
	mux.Handle("GET /{$}", s.auth(http.HandlerFunc(s.overview)))
	mux.Handle("GET /s/{subject}", s.auth(http.HandlerFunc(s.subject)))
	mux.Handle("GET /s/{subject}/{file}", s.auth(http.HandlerFunc(s.reportPage)))
	return securityHeaders(mux)
}

func securityHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("Referrer-Policy", "no-referrer")
		w.Header().Set("Content-Security-Policy", "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src data:")
		next.ServeHTTP(w, r)
	})
}

// auth accepts "Authorization: Bearer <token>" (API clients) or HTTP Basic auth
// with the token as password (browsers). With no token configured it is a no-op.
func (s *Server) auth(next http.Handler) http.Handler {
	if s.cfg.Token == "" {
		return next
	}
	want := []byte(s.cfg.Token)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		got := ""
		if b, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer "); ok {
			got = b
		} else if _, p, ok := r.BasicAuth(); ok {
			got = p
		}
		if subtle.ConstantTimeCompare([]byte(got), want) != 1 {
			w.Header().Set("WWW-Authenticate", `Basic realm="secbaseline", charset="UTF-8"`)
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func (s *Server) upload(w http.ResponseWriter, r *http.Request) {
	data, err := io.ReadAll(http.MaxBytesReader(w, r.Body, maxUpload))
	if err != nil {
		http.Error(w, "report too large or unreadable", http.StatusRequestEntityTooLarge)
		return
	}
	id, err := s.store.Save(data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"id": id, "url": "/s/" + id})
}

// SubjectSummary is one row of the overview.
type SubjectSummary struct {
	ID          string         `json:"id"`
	Subject     string         `json:"subject"`
	Platform    string         `json:"platform"`
	Latest      runner.Summary `json:"latest"`
	LatestFile  string         `json:"latest_file"`
	LastSeen    time.Time      `json:"last_seen"`
	Reports     int            `json:"reports"`
	HasPrevious bool           `json:"has_previous"`
	HasDelta    bool           `json:"has_delta"` // the latest and previous reports both have a score
	Delta       float64        `json:"delta"`
	Regressions int            `json:"regressions"`
	Drift       bool           `json:"drift"`
}

func (s *Server) summaries() ([]SubjectSummary, error) {
	ids, err := s.store.Subjects()
	if err != nil {
		return nil, err
	}
	var out []SubjectSummary
	for _, id := range ids {
		files, err := s.store.History(id)
		if err != nil || len(files) == 0 {
			continue
		}
		latest, err := s.store.Load(id, files[len(files)-1])
		if err != nil {
			continue
		}
		sum := SubjectSummary{ID: id, Subject: drift.Subject(latest), Platform: latest.Platform.Name, Latest: latest.Summary,
			LatestFile: files[len(files)-1], LastSeen: latest.StartedAt, Reports: len(files)}
		if len(files) > 1 {
			if prev, err := s.store.Load(id, files[len(files)-2]); err == nil {
				d := drift.Compare(prev, latest)
				sum.HasPrevious, sum.HasDelta, sum.Delta, sum.Regressions, sum.Drift = true, d.HasDelta(), d.ScoreDelta, len(d.Regressions), d.HasDrift()
			}
		}
		out = append(out, sum)
	}
	// Worst first: regressions, then lowest score; reports without a score last.
	slices.SortStableFunc(out, func(a, b SubjectSummary) int {
		if a.Regressions != b.Regressions {
			return b.Regressions - a.Regressions
		}
		switch {
		case a.Latest.HasScore() != b.Latest.HasScore():
			if a.Latest.HasScore() {
				return -1
			}
			return 1
		case a.Latest.Score < b.Latest.Score:
			return -1
		case a.Latest.Score > b.Latest.Score:
			return 1
		}
		return strings.Compare(a.ID, b.ID)
	})
	return out, nil
}

func (s *Server) apiSubjects(w http.ResponseWriter, r *http.Request) {
	subs, err := s.summaries()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(subs)
}

func (s *Server) overview(w http.ResponseWriter, r *http.Request) {
	subs, err := s.summaries()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	s.render(w, "overview", map[string]any{"Subjects": subs, "Version": s.cfg.Version})
}

type historyRow struct {
	File    string
	Started time.Time
	Summary runner.Summary
}

func (s *Server) subject(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("subject")
	files, err := s.store.History(id)
	if err != nil || len(files) == 0 {
		http.NotFound(w, r)
		return
	}
	var rows []historyRow
	var reps []*runner.Report
	for _, f := range files {
		rep, err := s.store.Load(id, f)
		if err != nil {
			continue
		}
		reps = append(reps, rep)
		rows = append(rows, historyRow{File: f, Started: rep.StartedAt, Summary: rep.Summary})
	}
	if len(reps) == 0 {
		http.NotFound(w, r)
		return
	}
	latest := reps[len(reps)-1]
	data := map[string]any{
		"ID": id, "Subject": drift.Subject(latest), "Platform": latest.Platform.Name, "Latest": latest,
		"LatestFile": rows[len(rows)-1].File, "Rows": reverse(rows), "Trend": trend(rows), "Version": s.cfg.Version,
	}
	if len(reps) > 1 {
		data["Drift"] = drift.Compare(reps[len(reps)-2], latest)
	}
	s.render(w, "subject", data)
}

func (s *Server) reportPage(w http.ResponseWriter, r *http.Request) {
	rep, err := s.store.Load(r.PathValue("subject"), r.PathValue("file"))
	if err != nil {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := report.WriteHTML(w, rep); err != nil {
		log.Printf("render report: %v", err)
	}
}

func (s *Server) render(w http.ResponseWriter, name string, data any) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := pages.ExecuteTemplate(w, name, data); err != nil {
		log.Printf("render %s: %v", name, err)
	}
}

// trend returns SVG polyline points for the score history (oldest left),
// skipping reports without a score, or "" when fewer than two have one.
func trend(rows []historyRow) string {
	// Plot area: x from left to width-pad (labels sit left of it), y from pad to height-pad.
	const width, height, pad, left = 600.0, 120.0, 10.0, 44.0
	var pts []string
	step := 0.0
	if len(rows) > 1 {
		step = (width - pad - left) / float64(len(rows)-1)
	}
	for i, r := range rows {
		if !r.Summary.HasScore() {
			continue
		}
		x := left + step*float64(i)
		y := height - pad - r.Summary.Score/100*(height-2*pad)
		pts = append(pts, fmt.Sprintf("%.1f,%.1f", x, y))
	}
	if len(pts) < 2 {
		return ""
	}
	return strings.Join(pts, " ")
}

func reverse[T any](s []T) []T {
	out := slices.Clone(s)
	slices.Reverse(out)
	return out
}

// Upload sends a report to a dashboard started with `checklist serve`.
func Upload(ctx context.Context, baseURL, token string, body []byte) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, strings.TrimRight(baseURL, "/")+"/api/reports", strings.NewReader(string(body)))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := (&http.Client{Timeout: 60 * time.Second}).Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	msg, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
	if resp.StatusCode != http.StatusCreated {
		return "", fmt.Errorf("upload failed: %s: %s", resp.Status, strings.TrimSpace(string(msg)))
	}
	var out struct{ URL string }
	json.Unmarshal(msg, &out)
	return strings.TrimRight(baseURL, "/") + out.URL, nil
}

// TokenFromEnv returns the shared token from CHECKLIST_SERVER_TOKEN.
func TokenFromEnv() string { return os.Getenv("CHECKLIST_SERVER_TOKEN") }
