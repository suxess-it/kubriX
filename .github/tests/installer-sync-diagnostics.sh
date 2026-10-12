#!/usr/bin/env bash
# Tests cached-status diagnostics without a cluster or installer side effects.
set -euo pipefail
cd "$(dirname "$0")/../.."
source <(sed -n '/^observe_sync_diagnostics() {/,/^wait_until_apps_synced_healthy() {/p' install-platform.sh | sed '$d')
start=$SECONDS
sync_wait_id=test-wait
synced=Synced
healthy=Healthy
KUBRIX_SYNC_DEBUG=true
declare -A diagnostic_last_state=() diagnostic_first_ready=() diagnostic_was_ready=()
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
grep -q 'event=end .*all-ready=true' "$log"
grep -q 'app=sx-example installer-retries=0 .*observed-failed-operations=0 readiness-regressions=0 first-ready-after=' "$log"
echo "Installer diagnostic failure deduplication, retry reset, readiness regression and quiet-mode checks passed."
