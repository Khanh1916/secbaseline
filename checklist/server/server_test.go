package server

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"checklist/runner"
)

func sample(t *testing.T, at time.Time, status string, ports string) []byte {
	t.Helper()
	pass, fail := 1, 0
	if status == runner.StatusFail {
		pass, fail = 0, 1
	}
	rep := runner.Report{
		SchemaVersion: runner.SchemaVersion,
		Platform:      runner.PlatformInfo{Key: "ubuntu", Name: "Ubuntu", Kind: "linux"},
		Host:          runner.Host{Hostname: "web01"},
		StartedAt:     at,
		Summary:       runner.Summary{Total: 1, Pass: pass, Fail: fail, Score: float64(pass * 100)},
		Checks:        []runner.CheckResult{{Key: "linux.ssh.root", ID: "1075", Title: "Ensure SSH root login is disabled", Section: "ssh", Status: status}},
		Collectors:    []runner.CollectorResult{{Key: "collect.listening_ports", Title: "Ports", Status: "ok", Output: ports}},
	}
	b, err := json.Marshal(rep)
	if err != nil {
		t.Fatal(err)
	}
	return b
}

func newTest(t *testing.T, token string) *httptest.Server {
	t.Helper()
	srv, err := New(Config{DataDir: t.TempDir(), Token: token, Version: "test"})
	if err != nil {
		t.Fatal(err)
	}
	ts := httptest.NewServer(srv.Handler())
	t.Cleanup(ts.Close)
	return ts
}

func get(t *testing.T, url string, user, pass string) (int, string) {
	t.Helper()
	req, _ := http.NewRequest(http.MethodGet, url, nil)
	if pass != "" {
		req.SetBasicAuth(user, pass)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	b, _ := io.ReadAll(resp.Body)
	return resp.StatusCode, string(b)
}

func TestUploadAndDashboard(t *testing.T) {
	ts := newTest(t, "s3cret")
	ctx := context.Background()
	day := time.Date(2026, 10, 17, 8, 0, 0, 0, time.UTC)

	if _, err := Upload(ctx, ts.URL, "wrong", sample(t, day, "pass", "0.0.0.0:22/TCP")); err == nil {
		t.Fatal("upload with a wrong token succeeded")
	}
	if _, err := Upload(ctx, ts.URL, "s3cret", sample(t, day, "pass", "0.0.0.0:22/TCP")); err != nil {
		t.Fatal(err)
	}
	url, err := Upload(ctx, ts.URL, "s3cret", sample(t, day.Add(24*time.Hour), "fail", "0.0.0.0:22/TCP\n0.0.0.0:4444/TCP"))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(url, "/s/ubuntu_web01/20261018T080000Z-") {
		t.Errorf("upload url = %s", url)
	}

	if code, _ := get(t, ts.URL+"/", "", ""); code != http.StatusUnauthorized {
		t.Errorf("overview without credentials = %d", code)
	}
	code, body := get(t, ts.URL+"/", "admin", "s3cret")
	if code != 200 || !strings.Contains(body, "web01") || !strings.Contains(body, "-100.0") {
		t.Errorf("overview = %d\n%s", code, body)
	}
	code, body = get(t, ts.URL+"/s/ubuntu_web01", "admin", "s3cret")
	for _, want := range []string{"Regressions (1)", "Ensure SSH root login is disabled", "+ 0.0.0.0:4444/TCP", "<polyline"} {
		if !strings.Contains(body, want) {
			t.Errorf("subject page (%d) missing %q", code, want)
		}
	}
	code, body = get(t, url, "admin", "s3cret")
	if code != 200 || !strings.Contains(body, "Security compliance report") {
		t.Errorf("report page = %d", code)
	}
}

func TestRejectsBadInput(t *testing.T) {
	ts := newTest(t, "")
	for _, path := range []string{"/s/..%2f..%2fetc", "/s/ubuntu_web01/..%2f..%2fx.json", "/s/nope"} {
		if code, _ := get(t, ts.URL+path, "", ""); code != http.StatusNotFound {
			t.Errorf("GET %s = %d, want 404", path, code)
		}
	}
	resp, err := http.Post(ts.URL+"/api/reports", "application/json", strings.NewReader(`{"schema_version": 99}`))
	if err != nil {
		t.Fatal(err)
	}
	resp.Body.Close()
	if resp.StatusCode != http.StatusBadRequest {
		t.Errorf("bad report = %d", resp.StatusCode)
	}
}

func TestRefusesPublicListenWithoutToken(t *testing.T) {
	srv, err := New(Config{Addr: "0.0.0.0:0", DataDir: t.TempDir()})
	if err != nil {
		t.Fatal(err)
	}
	if err := srv.ListenAndServe(context.Background()); err == nil || !strings.Contains(err.Error(), "token") {
		t.Fatalf("err = %v", err)
	}
}
