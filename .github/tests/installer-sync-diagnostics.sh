#!/usr/bin/env bash
# Tests cached-status diagnostics without a cluster or installer side effects.
set -euo pipefail
cd "$(dirname "$0")/../.."
source <(sed -n '/^sync_debug_printf() {/,/^wait_until_apps_synced_healthy() {/p' install-platform.sh | sed '$d')
start=$SECONDS
sync_wait_id=test-wait
synced=Synced
healthy=Healthy
KUBRIX_SYNC_DEBUG=true
declare -A diagnostic_last_state=() diagnostic_first_ready=() diagnostic_was_ready=()
declare -A diagnostic_resource_snapshot=()
declare -A diagnostic_regressions=() diagnostic_max_retry=() diagnostic_failures=() diagnostic_seen_failure=()
log=$(mktemp)
trap 'rm -f "$log"' EXIT

running='{"status":{"sync":{"status":"OutOfSync"},"health":{"status":"Progressing"},"operationState":{"phase":"Running","startedAt":"2026-10-12T00:00:00Z","retryCount":3}}}'
ready='{"status":{"sync":{"status":"Synced"},"health":{"status":"Healthy"},"operationState":{"phase":"Succeeded","startedAt":"2026-10-12T00:00:01Z","retryCount":0}}}'
failed='{"status":{"sync":{"status":"OutOfSync"},"health":{"status":"Degraded"},"conditions":[{"type":"SyncError","message":"must-not-be-logged"}],"operationState":{"phase":"Failed","startedAt":"2026-10-12T00:00:02Z","retryCount":1,"syncResult":{"resources":[{"group":"postgresql.cnpg.io","kind":"Cluster","namespace":"backstage","name":"database","status":"SyncFailed","message":"must-not-be-logged"}]}}}}'
observe_sync_diagnostics sx-example "$running" >> "$log"
observe_sync_diagnostics sx-example "$running" >> "$log"
[[ $(wc -l < "$log") -eq 1 ]]
observe_sync_diagnostics sx-example "$ready" >> "$log"
first_ready=${diagnostic_first_ready[sx-example]}
observe_sync_diagnostics sx-example "$failed" >> "$log"
observe_sync_diagnostics sx-example "$failed" >> "$log"
[[ ${diagnostic_failures[sx-example]} == 1 ]]
[[ ${diagnostic_regressions[sx-example]} == 1 ]]
[[ ${diagnostic_max_retry[sx-example]} == 3 ]]
second_failure=$(jq '.status.operationState.startedAt = "2026-10-12T00:00:03Z"' <<< "$failed")
observe_sync_diagnostics sx-example "$second_failure" >> "$log"
[[ ${diagnostic_failures[sx-example]} == 2 ]]
observe_sync_diagnostics sx-example "$ready" >> "$log"
[[ ${diagnostic_first_ready[sx-example]} == "$first_ready" ]]
[[ ${diagnostic_regressions[sx-example]} == 1 ]]
observe_sync_diagnostics sx-missing '{}' >> "$log"
[[ -z ${diagnostic_first_ready[sx-missing]+x} ]]
grep -q 'conditions=SyncError failed-resources=postgresql.cnpg.io/Cluster:backstage/database' "$log"
if grep -q 'must-not-be-logged' "$log"; then
  echo "Unexpected raw condition/resource message in diagnostics" >&2
  exit 1
fi
KUBRIX_SYNC_DEBUG=false
observe_sync_diagnostics sx-quiet "$ready" >> "$log"
if grep -q 'app=sx-quiet' "$log"; then
  echo "Verbose diagnostics should be disabled" >&2
  exit 1
fi
# Exercise the real wait loop with ready cached data and mocked cluster commands.
source <(sed -n '/^wait_until_apps_synced_healthy() {/,/^analyze_all_unhealthy_apps() {/p' install-platform.sh | sed '$d')
utc_now_seconds() { date -u +%s; }
kubectl() {
  if [[ "$*" == *"get pod"* ]]; then
    printf '%s' mock-controller
  else
    printf '%s' '{"status":{"sync":{"status":"Synced"},"health":{"status":"Healthy"}}}'
  fi
}
column() { cat; }
wait_until_apps_synced_healthy "sx-example" Synced Healthy 10 >> "$log"
grep -q '\[sync-summary\].*all-ready=true' "$log"
grep -q 'recovery-syncs=0 observed-failed-operations=0 readiness-regressions=0 all-ready=true' "$log"
if grep -q '\[sync-debug\].*installer-retries=0' "$log"; then
  echo "Quiet wait should not print detailed app statistics" >&2
  exit 1
fi
echo "Installer diagnostic failure deduplication, retry reset, readiness regression and quiet-mode checks passed."

# With debug enabled, retain internal markers and full per-app statistics.
debug_wait_output=$(KUBRIX_SYNC_DEBUG=true wait_until_apps_synced_healthy "sx-example" Synced Healthy 10)
grep -q '\[sync-timing\].*event=end' <<< "$debug_wait_output"
grep -q '\[sync-debug\].*app=sx-example installer-retries=0' <<< "$debug_wait_output"
unset KUBRIX_SYNC_DEBUG
default_wait_output=$(wait_until_apps_synced_healthy "sx-example" Synced Healthy 10)
grep -q '\[sync-summary\].*all-ready=true' <<< "$default_wait_output"
if grep -qE '\[sync-debug\]|\[sync-timing\]' <<< "$default_wait_output"; then
  echo "Default mode should not emit detailed diagnostics or internal markers" >&2
  exit 1
fi

# Recovery must not race a live operation or disable the stuck-hook watchdog.
mock_dir=$(mktemp -d)
trap 'rm -f "$log"; rm -rf "$mock_dir"' EXIT
end=$((SECONDS + 1000))
controller_pod=mock-controller
declare -A installer_sync_attempts=()
kubectl() {
  if [[ "$1" == get ]]; then
    cat "$mock_dir/status.json"
  elif [[ "$*" == *"terminate-op"* ]]; then
    echo terminate >> "$mock_dir/commands"
    case "$mock_mode" in
      terminate) printf '%s' "$failed_state" > "$mock_dir/status.json" ;;
      complete) printf '%s' "$success_state" > "$mock_dir/status.json" ;;
      newer) printf '%s' "$newer_state" > "$mock_dir/status.json" ;;
    esac
  elif [[ "$*" == *"app sync"* ]]; then
    echo sync >> "$mock_dir/commands"
    [[ "$mock_mode" != rejected ]]
  fi
}
sleep() { SECONDS=$((SECONDS + $1)); }
running_state='{"operation":{},"status":{"operationState":{"phase":"Running","startedAt":"2026-10-12T00:00:00Z"}}}'
failed_state='{"status":{"operationState":{"phase":"Failed","startedAt":"2026-10-12T00:00:00Z"}}}'
success_state='{"status":{"operationState":{"phase":"Succeeded","startedAt":"2026-10-12T00:00:00Z"}}}'
newer_state='{"operation":{},"status":{"operationState":{"phase":"Running","startedAt":"2026-10-12T00:01:00Z"}}}'
reset_recovery() {
  printf '%s' "$1" > "$mock_dir/status.json"
  : > "$mock_dir/commands"
  installer_sync_attempts=()
  mock_mode="$2"
}
reset_recovery "$running_state" terminate
restart_app_sync sx-example 2026-10-12T00:00:00 running-over-300s >> "$log"
[[ $(cat "$mock_dir/commands") == $'terminate\nsync' ]]
[[ ${installer_sync_attempts[sx-example]} == 1 ]]

# Natural completion between terminate and restart needs no further sync.
reset_recovery "$running_state" complete
if restart_app_sync sx-example 2026-10-12T00:00:00 running-over-300s >> "$log"; then exit 1; fi
[[ $(cat "$mock_dir/commands") == terminate ]]
[[ ${installer_sync_attempts[sx-example]:-0} == 0 ]]

# A newer automated operation must never be terminated.
reset_recovery "$newer_state" terminate
if restart_app_sync sx-example 2026-10-12T00:00:00 running-over-300s >> "$log"; then exit 1; fi
[[ ! -s "$mock_dir/commands" ]]
reset_recovery "$running_state" newer
if restart_app_sync sx-example 2026-10-12T00:00:00 running-over-300s >> "$log"; then exit 1; fi
[[ $(cat "$mock_dir/commands") == terminate ]]

# Incomplete termination is bounded and must not submit a new sync.
reset_recovery "$running_state" stuck
before=$SECONDS
if restart_app_sync sx-example 2026-10-12T00:00:00 running-over-300s >> "$log"; then exit 1; fi
[[ $((SECONDS-before)) -ge 30 && $((SECONDS-before)) -le 32 ]]
[[ $(cat "$mock_dir/commands") == terminate ]]
reset_recovery "$running_state" terminate
if restart_app_sync sx-example "" monitoring-resync >> "$log"; then exit 1; fi
[[ ! -s "$mock_dir/commands" ]]

# Failed operations can restart directly; rejection is not counted as success.
reset_recovery "$failed_state" terminate
restart_app_sync sx-example 2026-10-12T00:00:00 failed-or-error >> "$log"
[[ $(cat "$mock_dir/commands") == sync ]]
reset_recovery "$failed_state" rejected
if restart_app_sync sx-example 2026-10-12T00:00:00 failed-or-error >> "$log"; then exit 1; fi
[[ ${installer_sync_attempts[sx-example]:-0} == 0 ]]
echo "Serialized sync recovery and stuck-hook watchdog checks passed."

grep -q '\[sync-recovery\].*action=terminate' "$log"
grep -q '\[sync-recovery\].*reason=operation-still-active' "$log"
grep -q '\[sync-recovery\].*reason=sync-request-rejected' "$log"
echo "Default/debug output and visible recovery warning checks passed."

# Resource reasons: omit healthy/unassessed resources, retain drift/degradation,
# distinguish operation/hook errors, deduplicate, and suppress in default mode.
KUBRIX_SYNC_DEBUG=true
resource_log=$(mktemp)
trap 'rm -f "$log" "$resource_log"; rm -rf "$mock_dir"' EXIT
resource_status='{"status":{"resources":[
  {"kind":"Deployment","namespace":"app","name":"ok","status":"Synced","health":{"status":"Healthy"}},
  {"kind":"ConfigMap","namespace":"app","name":"config","status":"Synced"},
  {"group":"apps","kind":"Deployment","namespace":"app","name":"broken","status":"Synced","health":{"status":"Degraded","message":"Progress deadline exceeded"}},
  {"kind":"Service","namespace":"app","name":"drift","status":"OutOfSync","health":{"status":"Healthy"}},
  {"kind":"Secret","namespace":"app","name":"credentials","status":"OutOfSync","health":{"message":"do-not-print-secret"}}
],"conditions":[{"type":"ComparisonError","message":"cache unavailable"}],"operationState":{"phase":"Failed","startedAt":"2026-10-13T00:00:00Z","message":"Bearer FAKE-CREDENTIAL password=FAKE-PASSWORD","syncResult":{"resources":[
  {"kind":"Service","namespace":"app","name":"drift","status":"SyncFailed","message":"immutable field"},
  {"kind":"Job","namespace":"app","name":"hook","hookPhase":"Failed","message":"BackoffLimitExceeded"}
]}}}}'
observe_resource_diagnostics sx-resources "$resource_status" > "$resource_log"
grep -q 'Progress deadline exceeded' "$resource_log"
grep -q 'immutable field' "$resource_log"
grep -q 'BackoffLimitExceeded' "$resource_log"
grep -q 'cache unavailable' "$resource_log"
if grep -qE 'FAKE-CREDENTIAL|FAKE-PASSWORD|do-not-print-secret|app/ok|app/config' "$resource_log"; then exit 1; fi
before_lines=$(wc -l < "$resource_log")
observe_resource_diagnostics sx-resources "$resource_status" >> "$resource_log"
[[ $(wc -l < "$resource_log") == "$before_lines" ]]
changed_status=$(jq '.status.resources[2].health.message = "different reason"' <<< "$resource_status")
observe_resource_diagnostics sx-resources "$changed_status" >> "$resource_log"
grep -q 'different reason' "$resource_log"
observe_resource_diagnostics sx-resources '{}' >> "$resource_log"
grep -q 'issues-cleared=true' "$resource_log"
KUBRIX_SYNC_DEBUG=false
before_lines=$(wc -l < "$resource_log")
observe_resource_diagnostics sx-quiet-resources "$resource_status" >> "$resource_log"
[[ $(wc -l < "$resource_log") == "$before_lines" ]]
echo "Resource-level reasons, filtering, deduplication, redaction and debug gating checks passed."

# The real wait loop consumes the refreshed JSON rather than the stale snapshot.
kubectl() {
  if [[ "$*" == *"get pod"* ]]; then
    printf '%s' mock-controller
  elif [[ "$*" == *"--refresh"* ]]; then
    printf '%s' '{"metadata":{"name":"sx-refresh"},"status":{"sync":{"status":"Synced"},"health":{"status":"Healthy"}}}'
  else
    printf '%s' '{"metadata":{"name":"sx-refresh"},"status":{"sync":{"status":"OutOfSync"},"health":{"status":"Unknown"}}}'
  fi
}
KUBRIX_SYNC_DEBUG=true
refresh_output=$(wait_until_apps_synced_healthy "sx-refresh" Synced Healthy 10)
grep -q 'refresh=normal sync=Synced health=Healthy' <<< "$refresh_output"
grep -q 'all-ready=true' <<< "$refresh_output"
echo "Normal refresh consumes updated Application JSON in the same loop."

# Force refresh is gated by selection and successful token provisioning.
source <(sed -n '/^force_backstage_external_secret_refresh() {/,/^sync_debug_printf() {/p' install-platform.sh | sed '$d')
(
  cd "$mock_dir"
  KUBRIX_SYNC_DEBUG=false
  argocd_apps="sx-argocd"
  utc_now_seconds() { echo 1791918000; }
  timeout() {
    [[ "$1" == 20s && "$2" == kubectl ]] || return 99
    shift
    "$@"
  }
  kubectl() {
    # No kubectl config overrides: preserve automatic in-cluster auth.
    [[ "$*" != *"--request-timeout"* ]] || return 99
    printf '%s\n' "$*" >> force-commands
    if [[ "${refresh_mode:-success}" != success ]]; then
      printf '%s\n' 'Error from server (Forbidden): cannot patch externalsecrets' \
        'Bearer FAKE-CREDENTIAL token=FAKE-TOKEN' >&2
      return 7
    fi
  }
  : > force-commands
  force_backstage_external_secret_refresh
  [[ ! -s force-commands ]]
  argocd_apps="sx-argocd sx-backstage"
  force_backstage_external_secret_refresh
  [[ ! -s force-commands ]]
  touch backstage-openbao-secrets-created
  refresh_mode=failed
  force_backstage_external_secret_refresh > force-error-log
  [[ ! -f backstage-external-secret-refresh-requested ]]
  grep -q 'exit-code=7.*cannot patch externalsecrets' force-error-log
  [[ $(wc -l < force-error-log) -eq 1 ]]
  if grep -qE 'FAKE-CREDENTIAL|FAKE-TOKEN' force-error-log; then exit 1; fi
  # Same error stays quiet by default, but the request is still retried.
  force_backstage_external_secret_refresh >> force-error-log
  [[ $(wc -l < force-error-log) -eq 1 ]]
  [[ $(wc -l < force-commands) -eq 2 ]]
  [[ ! -f backstage-external-secret-refresh-requested ]]
  KUBRIX_SYNC_DEBUG=true
  force_backstage_external_secret_refresh >> force-error-log
  grep -q 'attempt=3 exit-code=7.*error=unchanged' force-error-log
  refresh_mode=success
  force_backstage_external_secret_refresh > force-log
  [[ -f backstage-external-secret-refresh-requested ]]
  [[ $(wc -l < force-commands) -eq 4 ]]
  grep -q 'annotate externalsecret.external-secrets.io sx-cnp-secret -n backstage force-sync=1791918000 --overwrite' force-commands
  grep -q 'force-sync=requested attempts=4' force-log
  force_backstage_external_secret_refresh
  [[ $(wc -l < force-commands) -eq 4 ]]
)
echo "Backstage force-refresh selection, token readiness, visible/redacted errors, retry and once-only checks passed."

# Real Git credential protocol: credentials must stay scoped to one invocation.
source <(sed -n '/^git_with_credentials() (/,/^# clone kubriX upstream/p' install-platform.sh | sed '$d')
(
  auth_dir=$(mktemp -d)
  trap 'rm -rf "$auth_dir"' EXIT
  export GIT_CONFIG_GLOBAL="$auth_dir/global" GIT_CONFIG_NOSYSTEM=1
  export AUTH_UP_USER=upstream-user AUTH_UP_TOKEN='upstream-token-special:@/?'
  export AUTH_CUSTOMER_USER=customer-user AUTH_CUSTOMER_TOKEN='customer-token-special:@/?'
  git config --global credential.helper "store --file=$auth_dir/credentials"
  printf 'protocol=https\nhost=github.com\n\n' > "$auth_dir/request"
  git_with_credentials AUTH_UP_USER AUTH_UP_TOKEN https://github.com/org/upstream.git \
    credential fill < "$auth_dir/request" > "$auth_dir/upstream"
  git_with_credentials AUTH_CUSTOMER_USER AUTH_CUSTOMER_TOKEN https://github.com/org/customer.git \
    credential fill < "$auth_dir/request" > "$auth_dir/customer"
  grep -Fxq "username=$AUTH_UP_USER" "$auth_dir/upstream"
  grep -Fxq "password=$AUTH_UP_TOKEN" "$auth_dir/upstream"
  grep -Fxq "username=$AUTH_CUSTOMER_USER" "$auth_dir/customer"
  grep -Fxq "password=$AUTH_CUSTOMER_TOKEN" "$auth_dir/customer"
  # No credential persistence, including pre-existing global credential stores.
  git_with_credentials AUTH_CUSTOMER_USER AUTH_CUSTOMER_TOKEN https://github.com/org/customer.git \
    credential approve < "$auth_dir/customer"
  [[ ! -e "$auth_dir/credentials" ]]
  printf 'protocol=https\nhost=other.example\n\n' > "$auth_dir/other"
  if git_with_credentials AUTH_UP_USER AUTH_UP_TOKEN https://github.com/org/upstream.git \
    credential fill < "$auth_dir/other" > "$auth_dir/refused" 2>/dev/null; then
    echo "Credentials must not be provided to another host" >&2
    exit 1
  fi
  if grep -q 'token-special' "$auth_dir/refused" "$auth_dir/global"; then exit 1; fi
  (
    set -x
    git_with_credentials AUTH_UP_USER AUTH_UP_TOKEN https://github.com/org/upstream.git \
      credential fill < "$auth_dir/request" > /dev/null
  ) 2> "$auth_dir/trace"
  if grep -q 'token-special' "$auth_dir/trace"; then exit 1; fi
)
echo "Real Git credential separation, host scoping, non-persistence and xtrace checks passed."

# Real HTTP Git backend: exercise actual bootstrap functions and customer clone.
python3 - <<'PY_GIT_AUTH'
import base64
import http.server
import os
import pathlib
import subprocess
import tempfile
import threading
import urllib.parse

def run(*args, **kwargs):
    result = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)
    if result.returncode:
        print(result.stdout.decode(), result.stderr.decode())
        result.check_returncode()
    return result

with tempfile.TemporaryDirectory() as tmp:
    root = pathlib.Path(tmp)
    source = pathlib.Path('install-platform.sh').read_text()
    helper = source[source.index('git_with_credentials() ('):source.index('bootstrap_template_downstream_repo() {')]
    push = source[source.index('bootstrap_push_to_downstream() {'):source.index('# Current UTC epoch seconds')]
    (root / 'functions.sh').write_text(helper + push)
    for name in ('upstream.git', 'customer.git', 'orphan.git'):
        run('git', 'init', '--bare', '--initial-branch=main', str(root / name))
        run('git', '-C', str(root / name), 'config', 'http.receivepack', 'true')
    run('git', 'clone', str(root / 'upstream.git'), str(root / 'seed'))
    run('git', '-C', str(root / 'seed'), 'config', 'user.name', 'Fixture')
    run('git', '-C', str(root / 'seed'), 'config', 'user.email', 'fixture@example.invalid')
    (root / 'seed' / 'seed.txt').write_text('upstream\n')
    run('git', '-C', str(root / 'seed'), 'add', '.')
    run('git', '-C', str(root / 'seed'), 'commit', '-m', 'seed')
    run('git', '-C', str(root / 'seed'), 'push', 'origin', 'main')
    backend = pathlib.Path(run('git', '--exec-path').stdout.decode().strip()) / 'git-http-backend'
    seen = []

    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def handle_git(self):
            url = urllib.parse.urlsplit(self.path)
            path = url.path
            upstream = path.startswith('/upstream.git/')
            expected = 'upstream-user:upstream-token' if upstream else 'customer-user:customer-token'
            auth = self.headers.get('Authorization', '')
            valid = auth == 'Basic ' + base64.b64encode(expected.encode()).decode()
            if not valid:
                self.send_response(401)
                self.send_header('WWW-Authenticate', 'Basic realm="fixture"')
                self.send_header('Content-Length', '0')
                self.end_headers()
                return
            seen.append(('upstream' if upstream else 'customer', self.command))
            # Exercise an actual same-host redirect without credentials in URL.
            if path.startswith('/customer.git/') and self.command == 'GET':
                self.send_response(307)
                self.send_header('Location', '/canonical' + self.path)
                self.send_header('Content-Length', '0')
                self.end_headers()
                return
            path = path.removeprefix('/canonical')
            env = dict(os.environ, GIT_PROJECT_ROOT=str(root), GIT_HTTP_EXPORT_ALL='1',
                       PATH_INFO=path, QUERY_STRING=url.query, REQUEST_METHOD=self.command,
                       CONTENT_TYPE=self.headers.get('Content-Type', ''),
                       CONTENT_LENGTH=self.headers.get('Content-Length', '0'), REMOTE_USER='fixture')
            body = self.rfile.read(int(env['CONTENT_LENGTH']))
            response = run(str(backend), input=body, env=env).stdout
            headers, _, content = response.partition(b'\r\n\r\n')
            self.send_response(200)
            for line in headers.decode().splitlines():
                key, value = line.split(':', 1)
                if key.lower() != 'status':
                    self.send_header(key, value.strip())
            self.end_headers()
            self.wfile.write(content)

        do_GET = handle_git
        do_POST = handle_git

    server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    base = 'http://127.0.0.1:' + str(server.server_port)
    env = dict(os.environ, KUBRIX_UPSTREAM_REPO=base + '/upstream.git',
               KUBRIX_UPSTREAM_REPO_USERNAME='upstream-user', KUBRIX_UPSTREAM_REPO_PASSWORD='upstream-token',
               KUBRIX_REPO_USERNAME='customer-user', KUBRIX_REPO_PASSWORD='customer-token',
               KUBRIX_UPSTREAM_BRANCH='main', KUBRIX_REPO_PROTO='http://',
               GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=str(root / 'empty-global'))
    for keep, target in [('true', 'customer.git'), ('false', 'orphan.git')]:
        work = root / ('work-' + keep)
        work.mkdir()
        env.update(KUBRIX_BOOTSTRAP_KEEP_HISTORY=keep, KUBRIX_REPO=base + '/' + target)
        script = '''set -euo pipefail
source "$1"
bootstrap_clone_from_upstream
printf 'customer\n' > customer.txt
bootstrap_push_to_downstream
if git config --get-regexp 'credential|remote.*url' | grep -qE 'upstream-token|customer-token'; then exit 1; fi
git_with_credentials KUBRIX_REPO_USERNAME KUBRIX_REPO_PASSWORD "$KUBRIX_REPO" clone "$KUBRIX_REPO" verify
test -f verify/customer.txt
'''
        run('bash', '-c', script, 'test', str(root / 'functions.sh'), env=env, cwd=work)
        count = run('git', '--git-dir', str(root / target), 'rev-list', '--count', 'main').stdout.strip()
        assert count == (b'2' if keep == 'true' else b'1'), count
    server.shutdown()
    assert ('upstream', 'GET') in seen and ('customer', 'POST') in seen
    print('Real authenticated HTTP clone/push/re-clone passed with distinct upstream/customer credentials, redirect, and both history modes.')

PY_GIT_AUTH
